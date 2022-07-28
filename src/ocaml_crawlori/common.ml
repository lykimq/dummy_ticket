open Tzfunc
open Proto
open Pg
open Crp

module Info = Info

open Info

type bigmap_types = {
  bmt_key: Mtyped.stype; [@encoding Mtyped.stype_enc.json]
  bmt_value: Mtyped.stype; [@encoding Mtyped.stype_enc.json]
} [@@deriving encoding]

type bigmap_info = {
  bm_id: z;
  bm_types: bigmap_types
} [@@deriving encoding]

module CSet = Set.Make(struct
type t = contract_info
let compare c1 c2 = String.compare c1.ci_address c2.ci_address
end)

type extra = {
mutable contracts : CSet.t [@set contract_info_enc] ;
} [@@deriving encoding]

type extra_config = <
  node: string option;
  originator_address : string option ;
  port: int option;
  batch_timeout: float; [@dft 60.]
  batch_load: A.uint64; [@dft 100L] [@encoding A.uint64_enc.json]
> [@@deriving encoding {ignore}]

module E = struct
  type extra = {
    mutable contracts : CSet.t [@set contract_info_enc] ;
    originator_address : string ;
} [@@deriving encoding]
end

let short ?(len=8) h =
  if String.length h > len then String.sub h 0 len else h

let use dbh f = match dbh with
  | None -> PG.Pool.use f
  | Some dbh -> f dbh

let get_info ?dbh () =
  use dbh @@ fun dbh ->
  let|>? l = [%pgsql.object dbh "select * from contracts"] in
  List.map Info.info_of_row l

let parse_file filename enc f =
  try f @@ EzEncoding.destruct enc filename
  with _ ->
    let ic = open_in filename in
    let s = really_input_string ic (in_channel_length ic) in
    close_in ic;
    try f @@ EzEncoding.destruct enc s
    with exn -> rerr @@ `generic ("config_error", Printexc.to_string exn)

let get_crawler_config filename =
  let aux c =
    let|>? extra = get_info () in
    { c with extra }, c.extra in
  parse_file filename (config_enc extra_config_enc) aux