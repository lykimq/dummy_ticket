open Pg
open Crp
open Common
open Info
open E

let insert_all_operations ?(forward=false) ~dbh ~contract ~op parameter =
let kind = parameter in

       [%pgsql dbh "insert into all_operations(contract,kind,transaction,block,index,level,tsp,main) values ($contract,$kind,${op.bo_hash},${op.bo_block},${op.bo_index},${op.bo_level},${op.bo_tsp},$forward)"]

let dummy_ticket_register ~dbh ~forward config address kind op=
let>? () = [%pgsql dbh "insert into contracts\
(address,kind,transaction,block,index,level,tsp,main) \
values \
($address,$kind,${op.bo_hash},${op.bo_block},${op.bo_index},\
${op.bo_level},${op.bo_tsp},$forward)"] in
config.contracts <- CSet.add (track_contract address kind) config.contracts ;
rok ()