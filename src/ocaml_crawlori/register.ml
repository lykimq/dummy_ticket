open Crawlori
open Common

let register_all_plugins config=
let open Make(Pg)(E) in
Plugins.register_mod (module Dummy_ticket_plugin)

;

Lwt.map (Result.iter_error Rp.print_error) @@
let>? () = init config in
loop config