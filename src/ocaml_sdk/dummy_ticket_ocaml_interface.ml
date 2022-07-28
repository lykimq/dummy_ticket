open Dummy_ticket_code
open Factori_types
open Tzfunc.Proto

type handle = {ticketer : address;owner : address;id : nat;data : bytes;amount : nat}

let handle_encode arg = Mprim {prim = `Pair;
args = [Mprim {prim = `Pair;
args = [Mprim {prim = `Pair;
args = [(nat_encode arg.amount);(bytes_encode arg.data)];
annots=[]}
;(nat_encode arg.id);(address_encode arg.owner)];
annots=[]}
;(address_encode arg.ticketer)];
annots=[]}

let handle_decode (m : micheline) : handle =
let (((amount,data),id,owner),ticketer) = (tuple2_decode (tuple3_decode (tuple2_decode nat_decode bytes_decode) nat_decode address_decode) address_decode) m in
{ticketer : address;owner : address;id : nat;data : bytes;amount : nat}

let handle_micheline = Mprim {prim = `pair;
args = [Mprim {prim = `pair;
args = [Mprim {prim = `pair;
args = [(nat_micheline);(bytes_micheline)];
annots=[]}
;(nat_micheline);(address_micheline)];
annots=[]}
;(address_micheline)];
annots=[]}

let handle_generator () = {ticketer = address_generator ();owner = address_generator ();id = nat_generator ();data = bytes_generator ();amount = nat_generator ()}


type withdraw_from_deku = {proof : (bytes *
 bytes) list;handles_hash : bytes;handle : handle;deku_consensus : address}

let withdraw_from_deku_encode arg = Mprim {prim = `Pair;
args = [Mprim {prim = `Pair;
args = [(address_encode arg.deku_consensus);(handle_encode arg.handle)];
annots=[]}
;(bytes_encode arg.handles_hash);((list_encode (tuple2_encode bytes_encode
bytes_encode)) arg.proof)];
annots=[]}

let withdraw_from_deku_decode (m : micheline) : withdraw_from_deku =
let ((deku_consensus,handle),handles_hash,proof) = (tuple3_decode (tuple2_decode address_decode handle_decode) bytes_decode (list_decode (tuple2_decode bytes_decode
bytes_decode))) m in
{proof : (bytes *
 bytes) list;handles_hash : bytes;handle : handle;deku_consensus : address}

let withdraw_from_deku_micheline = Mprim {prim = `pair;
args = [Mprim {prim = `pair;
args = [(address_micheline);(handle_micheline)];
annots=[]}
;(bytes_micheline);((list_micheline ((tuple2_micheline bytes_micheline
bytes_micheline))))];
annots=[]}

let withdraw_from_deku_generator () = {proof = (list_generator (tuple2_generator bytes_generator
bytes_generator)) ();handles_hash = bytes_generator ();handle = handle_generator ();deku_consensus = address_generator ()}

let call_withdraw_from_deku ?(node = Blockchain.default_node) ?(debug=false) ?(amount=0L) ~from ~kt1 (param : withdraw_from_deku) =
     let param =
     {
     entrypoint = EPnamed "withdraw_from_deku";
     value = Micheline (withdraw_from_deku_encode param);
     } in
     Blockchain.call_entrypoint ~debug ~node ~amount ~from ~dst:kt1 param


type mint_to_deku = {ticket_data : bytes;ticket_amount : nat;deku_recipient : address;deku_consensus : address}

let mint_to_deku_encode arg = Mprim {prim = `Pair;
args = [Mprim {prim = `Pair;
args = [(address_encode arg.deku_consensus);(address_encode arg.deku_recipient)];
annots=[]}
;(nat_encode arg.ticket_amount);(bytes_encode arg.ticket_data)];
annots=[]}

let mint_to_deku_decode (m : micheline) : mint_to_deku =
let ((deku_consensus,deku_recipient),ticket_amount,ticket_data) = (tuple3_decode (tuple2_decode address_decode address_decode) nat_decode bytes_decode) m in
{ticket_data : bytes;ticket_amount : nat;deku_recipient : address;deku_consensus : address}

let mint_to_deku_micheline = Mprim {prim = `pair;
args = [Mprim {prim = `pair;
args = [(address_micheline);(address_micheline)];
annots=[]}
;(nat_micheline);(bytes_micheline)];
annots=[]}

let mint_to_deku_generator () = {ticket_data = bytes_generator ();ticket_amount = nat_generator ();deku_recipient = address_generator ();deku_consensus = address_generator ()}

let call_mint_to_deku ?(node = Blockchain.default_node) ?(debug=false) ?(amount=0L) ~from ~kt1 (param : mint_to_deku) =
     let param =
     {
     entrypoint = EPnamed "mint_to_deku";
     value = Micheline (mint_to_deku_encode param);
     } in
     Blockchain.call_entrypoint ~debug ~node ~amount ~from ~dst:kt1 param

type burn_callback = bytes ticket
let burn_callback_encode (arg : burn_callback) : micheline = (ticket_encode (bytes_encode)) arg
let burn_callback_decode = (ticket_decode (bytes_decode))
let burn_callback_micheline = (ticket_micheline (bytes_micheline))
let burn_callback_generator () = (ticket_generator (bytes_generator)) ()

let call_burn_callback ?(node = Blockchain.default_node) ?(debug=false) ?(amount=0L) ~from ~kt1 (param : burn_callback) =
     let param =
     {
     entrypoint = EPnamed "burn_callback";
     value = Micheline (burn_callback_encode param);
     } in
     Blockchain.call_entrypoint ~debug ~node ~amount ~from ~dst:kt1 param

type storage = unit
let storage_encode : storage -> micheline = unit_encode
let storage_decode (m : micheline) : storage = unit_decode m
let storage_micheline = unit_micheline
let storage_generator () = unit_generator ()

let deploy ?(amount=0L) ?(node="https://tz.functori.com") ?(name="No name provided") ?(from=Blockchain.bootstrap1) storage =
               let storage = storage_encode storage in
               Blockchain.deploy ~amount ~node ~name ~from ~code (Micheline storage)

let test_storage_download ~kt1 ~base () =
     let open Tzfunc.Rp in
     let open Blockchain in
     Lwt_main.run @@
     let>? storage = get_storage ~base ~debug:(!Factori_types.debug > 0) kt1 storage_decode in
     let storage_reencoded = storage_encode storage in
     Lwt.return_ok @@ Factori_types.output_debug @@ Format.asprintf "Done downloading storage: %s."
     (Ezjsonm_interface.to_string
     (Json_encoding.construct
     micheline_enc.json
     storage_reencoded))