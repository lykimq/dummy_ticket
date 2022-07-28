let downgrade = [
"drop dummy_ticket_storage cascade";
"drop dummy_ticket_burn_callback cascade";
"drop dummy_ticket_mint_to_deku cascade";
"drop dummy_ticket_withdraw_from_deku cascade";
]

let upgrade = ["create table dummy_ticket_storage(\
contract varchar not null, \
transaction varchar not null, \
block varchar not null, \
index int not null, \
level int not null, \
tsp timestamp not null, \
main boolean not null, \
storage_content jsonb not null)" ;

"create index dummy_ticket_storage_contract_index on dummy_ticket_storage(contract)" ;
"create index dummy_ticket_storage_block_index on dummy_ticket_storage(block)" ;
"create index dummy_ticket_storage_level_index on dummy_ticket_storage(level)" ;
"create index dummy_ticket_storage_tsp_index on dummy_ticket_storage(tsp)" ;
"create index dummy_ticket_storage_main_index on dummy_ticket_storage(main)" ;

"create table dummy_ticket_burn_callback(\
contract varchar not null, \
transaction varchar not null, \
block varchar not null, \
index int not null, \
level int not null, \
tsp timestamp not null, \
main boolean not null, \
burn_callback_parameter jsonb not null)" ;

"create index dummy_ticket_burn_callback_contract_index on dummy_ticket_burn_callback(contract)" ;
"create index dummy_ticket_burn_callback_block_index on dummy_ticket_burn_callback(block)" ;
"create index dummy_ticket_burn_callback_level_index on dummy_ticket_burn_callback(level)" ;
"create index dummy_ticket_burn_callback_tsp_index on dummy_ticket_burn_callback(tsp)" ;
"create index dummy_ticket_burn_callback_main_index on dummy_ticket_burn_callback(main)" ;

"create table dummy_ticket_mint_to_deku(\
contract varchar not null, \
transaction varchar not null, \
block varchar not null, \
index int not null, \
level int not null, \
tsp timestamp not null, \
main boolean not null, \
mint_to_deku_parameter jsonb not null)" ;

"create index dummy_ticket_mint_to_deku_contract_index on dummy_ticket_mint_to_deku(contract)" ;
"create index dummy_ticket_mint_to_deku_block_index on dummy_ticket_mint_to_deku(block)" ;
"create index dummy_ticket_mint_to_deku_level_index on dummy_ticket_mint_to_deku(level)" ;
"create index dummy_ticket_mint_to_deku_tsp_index on dummy_ticket_mint_to_deku(tsp)" ;
"create index dummy_ticket_mint_to_deku_main_index on dummy_ticket_mint_to_deku(main)" ;

"create table dummy_ticket_withdraw_from_deku(\
contract varchar not null, \
transaction varchar not null, \
block varchar not null, \
index int not null, \
level int not null, \
tsp timestamp not null, \
main boolean not null, \
withdraw_from_deku_parameter jsonb not null)" ;

"create index dummy_ticket_withdraw_from_deku_contract_index on dummy_ticket_withdraw_from_deku(contract)" ;
"create index dummy_ticket_withdraw_from_deku_block_index on dummy_ticket_withdraw_from_deku(block)" ;
"create index dummy_ticket_withdraw_from_deku_level_index on dummy_ticket_withdraw_from_deku(level)" ;
"create index dummy_ticket_withdraw_from_deku_tsp_index on dummy_ticket_withdraw_from_deku(tsp)" ;
"create index dummy_ticket_withdraw_from_deku_main_index on dummy_ticket_withdraw_from_deku(main)" ;
]