let downgrade = [
"drop contracts cascade";
]

let upgrade = ["create table contracts(\
address varchar not null, \
kind varchar not null, \
transaction varchar not null, \
block varchar not null, \
index int not null, \
level int not null, \
tsp timestamp not null, \
main boolean not null)" ;

"create index contracts_address_index on contracts(address)" ;
"create index contracts_kind_index on contracts(kind)" ;
"create index contracts_block_index on contracts(block)" ;
"create index contracts_level_index on contracts(level)" ;
"create index contracts_tsp_index on contracts(tsp)" ;
"create index contracts_main_index on contracts(main)" ;
]