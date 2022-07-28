open Tzfunc
open Proto
type z = (A.uzarith[@encoding A.uzarith_enc.json])[@@deriving encoding]

type contract_info = {ci_address : A.contract [@encoding A.contract_enc.json];ci_kind : string}[@@deriving encoding]
let info_of_row r=
{ci_address = r#address;
ci_kind = r#kind}

let track_contract address kind=
{ci_address = address;
ci_kind = kind}