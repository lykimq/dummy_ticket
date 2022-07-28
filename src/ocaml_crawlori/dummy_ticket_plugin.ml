
open Pg
open Crp
open Dummy_ticket_ocaml_interface
open Proto
open Common
open Info

type txn = Pg.txn
type init_acc = Pg.init_acc
include E

let mic_type_storage_ftype =
  match Mtyped.parse_type Dummy_ticket_ocaml_interface.storage_micheline with
  | Ok ftype -> ftype
  | Error _ -> failwith "can't parse factory generated storage type"

let mic_type_storage_type = Mtyped.short mic_type_storage_ftype

let always = true
let name = "dummy_ticket"
let forward_end _config _level = rok ()

let insert_dummy_ticket_storage ?(forward=false) ~dbh ~contract ~op parameter =
match parameter with
  | None -> rerr @@ `generic ("node_error", "no storage")
  | Some storage ->
    let p = EzEncoding.construct micheline_enc.json storage in
    [%pgsql dbh "insert into dummy_ticket_storage(contract,transaction,block,index,level,tsp,main,storage_content) values ($contract,${op.bo_hash},${op.bo_block},${op.bo_index},${op.bo_level},${op.bo_tsp},$forward,$p)"]

let insert_dummy_ticket_burn_callback ?(forward=false) ~dbh ~contract ~op parameter =
let p = EzEncoding.construct micheline_enc.json parameter in
[%pgsql dbh "insert into dummy_ticket_burn_callback(contract,transaction,block,index,level,tsp,main,burn_callback_parameter) values ($contract,${op.bo_hash},${op.bo_block},${op.bo_index},${op.bo_level},${op.bo_tsp},$forward,$p)"]

let insert_dummy_ticket_mint_to_deku ?(forward=false) ~dbh ~contract ~op parameter =
let p = EzEncoding.construct micheline_enc.json parameter in
[%pgsql dbh "insert into dummy_ticket_mint_to_deku(contract,transaction,block,index,level,tsp,main,mint_to_deku_parameter) values ($contract,${op.bo_hash},${op.bo_block},${op.bo_index},${op.bo_level},${op.bo_tsp},$forward,$p)"]

let insert_dummy_ticket_withdraw_from_deku ?(forward=false) ~dbh ~contract ~op parameter =
let p = EzEncoding.construct micheline_enc.json parameter in
[%pgsql dbh "insert into dummy_ticket_withdraw_from_deku(contract,transaction,block,index,level,tsp,main,withdraw_from_deku_parameter) values ($contract,${op.bo_hash},${op.bo_block},${op.bo_index},${op.bo_level},${op.bo_tsp},$forward,$p)"]

let get_storage_bms_id ?(allocs=[]) ~fields ~storage_type storage_value =
    ignore (allocs, fields, storage_type, storage_value); Ok()

let get_storage_ori ~allocs script =
  try
    let storage = storage_decode script.storage in
    let$ fields = Bm_utils.get_storage_fields script in
    let storage_type = mic_type_storage_ftype in
    let$ storage_value =
      Mtyped.(parse_value mic_type_storage_type script.storage) in
  let$ () =
    get_storage_bms_id ~allocs ~fields ~storage_type storage_value in
  Ok (storage)
  with exn ->
    let s = Printf.sprintf "decode_storage: %s" @@ Printexc.to_string exn in
    Error (`generic ("parse_error", s))



let insert_origination ?dbh ?(forward = false) config op ori =
  let address = Tzfunc.Crypto.op_to_KT1 op.bo_hash in
  if op.bo_op.source = config.originator_address then
    begin
    match op.bo_meta with
      | None -> rerr @@ `generic ("node_error", "no metadata")
      | Some meta ->
        let allocs = Bm_utils.big_map_allocs meta.op_lazy_storage_diff in
        match get_storage_ori ~allocs ori.script with
        | Error e ->
          Format.eprintf "Error %s@." @@ Tzfunc.Rp.string_of_error e ;
          rok ()
        | Ok (s) ->
          Format.printf "\027[0;93morigination %s\027[0m@." (short address) ;
          use dbh @@ fun dbh ->
          let storage = Some (storage_encode s) in
          let>? () = insert_dummy_ticket_storage ~dbh ~forward ~contract:address ~op storage in
          let>? () =
            Contracts.insert_all_operations
              ~forward ~dbh ~op ~contract:address "origination" in
          
          Contracts.dummy_ticket_register ~forward ~dbh config address "dummy_ticket" op 
    end
  else rok ()

let register_block ?forward config dbh b =
  let>? _ =
    fold (fun index op ->
        fold (fun index c ->
            match c.man_metadata with
            | None -> Lwt.return_ok index
            | Some meta ->
              if meta.man_operation_result.op_status = `applied then
                let>? index = match c.man_info.kind with
                  | Origination ori ->
                    let op = {
                      bo_block = b.hash; bo_level = b.header.shell.level;
                      bo_tsp = b.header.shell.timestamp; bo_hash = op.op_hash;
                      bo_op = c.man_info; bo_index = index; bo_indexes = (0l, 0l, 0l);
                      bo_meta = Option.map (fun m -> m.man_operation_result) c.man_metadata;
                      bo_numbers = Some c.man_numbers; bo_nonce = None;
                      bo_counter = c.man_numbers.counter } in
                    let|>? () = insert_origination ?forward config ~dbh op ori in
                    Int32.succ index
                  | _ -> Lwt.return_ok index in
                fold (fun index iop ->
                    if iop.in_result.op_status = `applied then
                      match iop.in_content.kind with
                      | Origination ori ->
                        let bo_meta = Some {
                            iop.in_result with
                            op_lazy_storage_diff =
                              iop.in_result.op_lazy_storage_diff @
                              (Option.fold ~none:[] ~some:(fun m ->
                                   m.man_operation_result.op_lazy_storage_diff)
                                  c.man_metadata) } in
                        let op = {
                          bo_block = b.hash; bo_level = b.header.shell.level;
                          bo_tsp = b.header.shell.timestamp; bo_hash = op.op_hash;
                          bo_op = iop.in_content; bo_index = index; bo_indexes = (0l, 0l, 0l); bo_meta;
                          bo_numbers = Some c.man_numbers; bo_nonce = Some iop.in_nonce;
                          bo_counter = c.man_numbers.counter } in
                        let|>? () = insert_origination ?forward config ~dbh op ori in
                        Int32.succ index
                      | _ -> Lwt.return_ok index
                    else
                      Lwt.return_ok index
                  ) index meta.man_internal_operation_results
              else Lwt.return_ok index
          ) index op.op_contents
      ) 0l b.operations in
  [%pgsql dbh
      "insert into state (level, tsp, chain_id) \
       values (${b.header.shell.level}, ${b.header.shell.timestamp}, \
       ${b.chain_id})"]


  let insert_operation ?forward dbh ~op ~contract parameter =
  match parameter with
  | None -> rerr @@ `generic ("operation_error", "no parameter")
  | Some p ->
    match p.entrypoint with
    | EPnamed "burn_callback" ->
      let>? () = Contracts.insert_all_operations ?forward ~dbh ~op ~contract "dummy_ticket_burn_callback" in
      insert_dummy_ticket_burn_callback ?forward ~dbh ~contract ~op p.value
| EPnamed "mint_to_deku" ->
      let>? () = Contracts.insert_all_operations ?forward ~dbh ~op ~contract "dummy_ticket_mint_to_deku" in
      insert_dummy_ticket_mint_to_deku ?forward ~dbh ~contract ~op p.value
| EPnamed "withdraw_from_deku" ->
      let>? () = Contracts.insert_all_operations ?forward ~dbh ~op ~contract "dummy_ticket_withdraw_from_deku" in
      insert_dummy_ticket_withdraw_from_deku ?forward ~dbh ~contract ~op p.value
    | _ ->
      let str =
        Format.sprintf "unexpected entrypoint %S" @@
        EzEncoding.construct entrypoint_enc.json p.entrypoint in
      rerr @@ `generic ("operation_error", str)

  let register_operation ?forward info dbh op =
  match op.bo_op.kind, op.bo_meta with
  | (Delegation _ | Reveal _ | Origination _ | Constant _ | Deposits_limit _|
    Tx_rollup_origination _ | Tx_rollup_submit_batch _|Tx_rollup_commit _|
    Tx_rollup_return_bond _|Tx_rollup_finalize_commitment _|
    Tx_rollup_remove_commitment _|Tx_rollup_rejection _|
    Tx_rollup_dispatch_tickets _|Transfer_ticket _|Sc_rollup_originate _|
    Sc_rollup_add_messages _|Sc_rollup_cement _|Sc_rollup_publish _), _ ->
    rok ()
  | _, None -> rerr @@ `generic ("node_error", "no metadata")
  | Transaction {destination=contract; parameters ; _}, Some meta ->
    match List.find_opt (fun c -> c.ci_address = contract && c.ci_kind = "dummy_ticket") @@ CSet.elements info.contracts with
    | None -> rok ()
    | Some info ->
      Format.printf "\027[0;35m[%s] transaction %s %s\027[0m@."
        name
        (String.sub op.bo_hash 0 10)
        (Option.fold ~none:"" ~some:(fun p ->
             EzEncoding.construct entrypoint_enc.json p.entrypoint) parameters) ;
      let>? () = insert_operation ?forward dbh ~op ~contract parameters in
      ignore info;
      insert_dummy_ticket_storage ~dbh ?forward ~contract ~op meta.op_storage


let set_main ?(forward=false) _info _dbh _m =
  if not forward then
    rok @@ fun () -> rok ()
  else rok @@ fun () -> rok ()


let init _config acc =
let l = [ Dummy_ticket_tables.upgrade, Dummy_ticket_tables.downgrade ] in
rok (acc @ l)

