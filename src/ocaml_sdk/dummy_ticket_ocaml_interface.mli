open Tzfunc.Proto
open Factori_types
(*Type definition for handle *)

type handle = {ticketer : address;owner : address;id : nat;data : bytes;amount : nat}


(** Encode elements of type handle into micheline *)
val handle_encode : handle -> micheline

(** Decode elements of type micheline as handle *)
val handle_decode : micheline -> handle

(** Generate random elements of type handle*)
val handle_generator : unit -> handle

(** The micheline type corresponding to type handle*)
val handle_micheline : micheline


(*Type definition for withdraw_from_deku *)

type withdraw_from_deku = {proof : (bytes *
 bytes) list;handles_hash : bytes;handle : handle;deku_consensus : address}


(** Encode elements of type withdraw_from_deku into micheline *)
val withdraw_from_deku_encode : withdraw_from_deku -> micheline

(** Decode elements of type micheline as withdraw_from_deku *)
val withdraw_from_deku_decode : micheline -> withdraw_from_deku

(** Generate random elements of type withdraw_from_deku*)
val withdraw_from_deku_generator : unit -> withdraw_from_deku

(** The micheline type corresponding to type withdraw_from_deku*)
val withdraw_from_deku_micheline : micheline



(** Call entrypoint withdraw_from_deku of the smart contract. *)
val call_withdraw_from_deku :   ?node:string -> ?debug:bool -> ?amount:int64 -> from:Blockchain.identity ->
                kt1:Tzfunc.Proto.A.contract ->
                withdraw_from_deku -> (string, Tzfunc__.Rp.error) result Lwt.t

(*Type definition for mint_to_deku *)

type mint_to_deku = {ticket_data : bytes;ticket_amount : nat;deku_recipient : address;deku_consensus : address}


(** Encode elements of type mint_to_deku into micheline *)
val mint_to_deku_encode : mint_to_deku -> micheline

(** Decode elements of type micheline as mint_to_deku *)
val mint_to_deku_decode : micheline -> mint_to_deku

(** Generate random elements of type mint_to_deku*)
val mint_to_deku_generator : unit -> mint_to_deku

(** The micheline type corresponding to type mint_to_deku*)
val mint_to_deku_micheline : micheline



(** Call entrypoint mint_to_deku of the smart contract. *)
val call_mint_to_deku :   ?node:string -> ?debug:bool -> ?amount:int64 -> from:Blockchain.identity ->
                kt1:Tzfunc.Proto.A.contract ->
                mint_to_deku -> (string, Tzfunc__.Rp.error) result Lwt.t

(*Type definition for burn_callback *)
type burn_callback = bytes ticket

(** Encode elements of type burn_callback into micheline *)
val burn_callback_encode : burn_callback -> micheline

(** Decode elements of type micheline as burn_callback *)
val burn_callback_decode : micheline -> burn_callback

(** Generate random elements of type burn_callback*)
val burn_callback_generator : unit -> burn_callback

(** The micheline type corresponding to type burn_callback*)
val burn_callback_micheline : micheline



(** Call entrypoint burn_callback of the smart contract. *)
val call_burn_callback :   ?node:string -> ?debug:bool -> ?amount:int64 -> from:Blockchain.identity ->
                kt1:Tzfunc.Proto.A.contract ->
                burn_callback -> (string, Tzfunc__.Rp.error) result Lwt.t

(*Type definition for storage *)
type storage = unit

(** Encode elements of type storage into micheline *)
val storage_encode : storage -> micheline

(** Decode elements of type micheline as storage *)
val storage_decode : micheline -> storage

(** Generate random elements of type storage*)
val storage_generator : unit -> storage

(** The micheline type corresponding to type storage*)
val storage_micheline : micheline



(** A function to deploy the smart contract.
           - amount is the initial balance of the contract
           - node allows to choose on which chain we are deploying
           - name allows to choose a name for the contract you are deploying
           - from is the account which will originate the contract (and pay for its origination)
           The function returns a pair (kt1,op_hash) where kt1 is the address of the contract
           and op_hash is the hash of the origination operation
       *)
val deploy :             ?amount:int64 ->
                         ?node:string ->
                         ?name:string ->
                         ?from:Blockchain.identity ->
                         storage -> (string * string, Tzfunc__.Rp.error) result Lwt.t

(** Downloads and decodes the storage, and then reencodes it.
Allows to check the robustness of the encoding and decoding functions. *)
val test_storage_download :
kt1:Proto.A.contract -> base:EzAPI__Url.TYPES.base_url -> unit -> (unit, Tzfunc__.Rp.error) result