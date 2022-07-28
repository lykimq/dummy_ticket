

let upgrade =
Static_tables.upgrade@
Contracts_table.upgrade@
Dummy_ticket_tables.upgrade

let downgrade =
Static_tables.downgrade@
Contracts_table.downgrade@
Dummy_ticket_tables.downgrade

let () =
  let database = Option.value ~default:Db_env.database (Sys.getenv_opt "PGDATABASE") in
  let upgrade0 dbh version =
    EzPG.upgrade ~dbh ~version ~downgrade:Tables.downgrade Tables.upgrade in
  let upgrade1 dbh version =
    EzPG.upgrade ~dbh ~version ~downgrade upgrade in
  let upgrades = [ 0, upgrade0; 1, upgrade1 ] in
  EzPGUpdater.main database ~upgrades
