let downgrade =
  [
    "drop state cascade";
    "drop all_operations cascade";
  ]

let upgrade =
  [
    "create domain zarith as numeric";
    "create or replace function zadd(z1 zarith, z2 zarith) returns zarith as \
     $$ begin return z1 + z2; end; $$ language plpgsql";
    "create or replace function zsub(z1 zarith, z2 zarith) returns zarith as \
     $$ begin return z1 - z2; end; $$ language plpgsql";
    "create or replace function zmul(z1 zarith, z2 zarith) returns zarith as \
     $$ begin return z1 * z2; end; $$ language plpgsql";
    "create or replace function zdiv(z1 zarith, z2 zarith) returns zarith as \
     $$ begin return z1 / z2; end; $$ language plpgsql";
    "create table state(level int not null, chain_id varchar not null, tsp \
     timestamp not null)";
    "create index state_level_index on state(level)";
    "create index state_chain_id_index on state(chain_id)";
    "create index state_tsp_index on state(tsp)";
    "create table all_operations(contract varchar not null, kind varchar not \
     null, transaction varchar not null, block varchar not null, index int not \
     null, level int not null, tsp timestamp not null, main boolean not null)";
    "create index all_operations_contract_index on all_operations(contract)";
    "create index all_operations_kind_index on all_operations(kind)";
    "create index all_operations_block_index on all_operations(block)";
    "create index all_operations_level_index on all_operations(level)";
    "create index all_operations_tsp_index on all_operations(tsp)";
    "create index all_operations_main_index on all_operations(main)";
  ]