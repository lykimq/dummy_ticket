
(
 (
  (Or
   (
    (Rule (typnam zarith))
    (Rule (colnam token_id))
    (Rule (colnam ledger_id))
    (Rule (colnam token_metadata_id))
    (Rule (colnam metadata_id))
    (Rule (colnam balance))
    (Rule (colnam diff))
    (Rule (colnam amount))
    (Rule (argnam token_id))
    (Rule (argnam metadata_id))
    )
   )
  (
   (serialize Z.to_string)
   (deserialize Z.of_string)
  )
 )
 (
  (Or
   (
    (Rule (typnam jsonb))
    (Rule (colnam license))
    (Rule (colnam source_code))
    (Rule (colnam errors))
    (Rule (colnam views))
    (Rule (colnam metadata))
    (Rule (colnam royalties))
    (Rule (colnam value))
    (Rule (colnam input))
    (Rule (colnam updates))
    (Rule (colnam creators))
    (Rule (colnam formats))
    (Rule (colnam attributes))
    (Rule (colnam royalties))
    (Rule (argnam metadata))
    (Rule (argnam input))
    (Rule (argnam updates))
    )
   )
  (
   (serialize json_to_string)
   (deserialize json_of_string)
  )
 )
)
