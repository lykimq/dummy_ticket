open Crawlori
open Crp
open Common

let filename = ref None

let dummy_extra_config = object
  method port = None
  method node = None
  method originator_address = Some "tz1..."
  method batch_timeout = 60.
  method batch_load = 100L
end

let dummy_config = {
  nodes = [ "https://tz.functori.com" ]; sleep = 6.; start = Some 13650000l;
  forward = None; verbose = 0; db_kind = `pg; step_forward = 20;
  confirmations_needed = 10l; plugins = []; retry = Some 5;
  retry_timeout = 10.; no_forward = false; extra = dummy_extra_config
}

let usage =
  Format.sprintf
    "usage: \027[0;93m./crawler <conf.json>\027[0m\n\n<config.json>:\n\027[0;96m%s\027[0m\n" @@
  EzEncoding.construct ~compact:false (config_enc extra_config_enc) dummy_config

let crawler config =
  Register.register_all_plugins config

(* TODO : WEBSOCKET ? *)
(* let api input =
 *   match input#port with
 *   | None -> Lwt.return_unit
 *   | Some port -> EzAPIServer.(server [ port, API Taktick_plugin.ppx_dir ]) *)

let () =
  Arg.parse [] (fun f -> filename := Some f) usage;
  match !filename with
  | None -> Arg.usage [] usage
  | Some filename ->
    EzLwtSys.run @@ fun () ->
    let> r = get_crawler_config filename in
    match r with
    | Error e -> Rp.print_error e; Lwt.return_unit
    | Ok (config, ext) ->
      Format.eprintf "Crawler Config: %s@." @@
      EzEncoding.construct extra_config_enc ext ;
      let config =
        { config with
          extra = { E.contracts = CSet.of_list config.extra ;
                    originator_address = Option.get ext#originator_address } } in
      Lwt.join [ crawler config(* ; api input *) ]
