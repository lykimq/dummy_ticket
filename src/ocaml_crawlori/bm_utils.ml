open Tzfunc
open Proto
open Crp
open Common

let big_map_allocs l =
  let f id key_type value_type =
    match Mtyped.parse_type key_type, Mtyped.parse_type value_type with
    | Error _, _ | _, Error _ -> id, None
    | Ok k, Ok v ->
      id, Some (Mtyped.short k, Mtyped.short v) in
  List.sort (fun (id1, _) (id2, _) -> compare id1 id2) @@
  List.filter_map (function
      | Big_map { id; diff = SDAlloc {key_type; value_type; _} } ->
        if id < Z.zero then None
        else Some (f id key_type value_type)
      | Big_map { id; diff = SDCopy {source; _} } ->
        List.find_map (function
            | Big_map { id = idc; diff = SDAlloc {key_type; value_type; _} }
              when source = Z.to_string idc ->
              Some (f id key_type value_type)
            | _ -> None) l
      | _ -> None) l

let get_big_map_id ~allocs bm_index k v =
  let rec aux i = function
    | [] -> None
    | _ :: t when i < bm_index -> aux (i+1) t
    | (id, t) :: _ ->
      match t with
      | Some (k2, v2) when k = k2 && v = v2 -> Some id
      | _ -> None in
  aux 0 allocs

let unexpected_michelson = Error `unexpected_michelson

let get_code_elt p = function
  | Mseq l ->
    List.find_map
      (function
        | Mprim { prim; args = [ arg ]; _} when prim = p -> Some arg
        | _ -> None) l
  | _ -> None

let get_storage_fields script =
  let rec aux bm_index acc = function
    | {Mtyped.typ=`tuple []; name = None} -> bm_index, acc
    | {Mtyped.typ=`tuple (h :: t); _} ->
      let bm_index, acc = aux bm_index acc h in
      aux bm_index acc {Mtyped.name=None; typ=`tuple t}
    | {Mtyped.name=Some n; typ = `big_map (k, v)} ->
      bm_index + 1, (n, Some (
          bm_index, Mtyped.short k, Mtyped.short v)) :: acc
    | {Mtyped.name=Some n; _} ->
      bm_index, (n, None) :: acc
    | _ -> bm_index, acc in
  match get_code_elt `storage script.code with
  | None -> unexpected_michelson
  | Some m -> match Mtyped.parse_type m with
    | Error e -> Error e
    | Ok t -> Ok (List.rev @@ snd @@ aux 0 [] t)

let match_fields ~expected ~allocs script =
  match get_storage_fields script, get_code_elt `storage script.code with
  | Error _, _ | _, None ->
    unexpected_michelson
  | Ok fields, Some storage_type ->
    let$ storage_type = try Mtyped.parse_type storage_type with _ -> unexpected_michelson in
    let$ storage_value = try Mtyped.(parse_value (short storage_type) script.storage) with _ -> unexpected_michelson in
    Ok (List.map (fun name ->
        match List.assoc_opt name fields with
        | None -> None, None
        | Some None ->
          Mtyped.search_value ~name storage_type storage_value, None
        | Some (Some (bm_index, k, v)) ->
          Mtyped.search_value ~name storage_type storage_value,
          (match get_big_map_id ~allocs bm_index k v with
           | None -> None
           | Some bm_id -> Some {bm_id; bm_types = {bmt_key=k; bmt_value=v}})
      ) expected)

let find_opt_storage_field ~allocs ~fields ~storage_type ~storage_value name =
  match List.assoc_opt name fields with
  | None -> None, None
  | Some None ->
    Mtyped.search_value ~name storage_type storage_value, None
  | Some (Some (bm_index, k, v)) ->
    Mtyped.search_value ~name storage_type storage_value,
    (match get_big_map_id ~allocs bm_index k v with
     | None -> None
     | Some bm_id -> Some {bm_id; bm_types = {bmt_key=k; bmt_value=v}})

let get_bm_updates ~bm_id ?key_decode ?value_decode l =
  List.flatten @@
  List.filter_map (function
      | Big_map { id=bid; diff = SDUpdate l }
      | Big_map { id=bid; diff = SDAlloc {updates=l; _} } when bid = bm_id ->
        Some (List.filter_map (fun {bm_key; bm_value; _} ->
            match bm_value with
            | None -> None
            | Some bmv ->
              try
                match key_decode, value_decode with
                | Some kd, Some vd ->
                  Some (kd bm_key, vd bmv)
                | _, _ ->
                  Some (bm_key, bmv)
              with _ -> None) l)
      | _ -> None) l