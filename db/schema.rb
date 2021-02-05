ActiveRecord::Schema.define(version: 2020_09_16_125326) do
  create_table "whois_records", id: :serial, force: :true do |t|
    t.integer "domain_id"
    t.string "name"
    t.text "body"
    t.json "json"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "registrar_id"
    t.index ["domain_id"], name: "index_whois_records_on_domain_id"
    t.index ["registrar_id"], name: "index_whois_records_on_registrar_id"
  end
end