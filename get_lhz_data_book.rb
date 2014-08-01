#-*- encoding: utf-8 -*-
require 'json/pure'
require 'net/http'
require 'uri'
require 'csv'

SKILL_API           = "http://lhrpg.com/lhz/api/skills.json"
ITEM_API            = "http://lhrpg.com/lhz/api/items.json"
PREFIXED_EFFECT_API = "http://lhrpg.com/lhz/api/prefixed_effects.json"

SKILL_LABEL = {
  "job_type"         => "特技種別",
  "type"             => "戦闘/一般",
  "name"             => "特技名",
  "skill_rank"       => "スキルランク",
  "skill_max_rank"   => "最大スキルランク",
  "timing"           => "タイミング",
  "roll"             => "判定",
  "target"           => "対象",
  "range"            => "射程",
  "cost"             => "コスト",
  "limit"            => "制限",
  "tags"             => "タグ",
  "function"         => "効果",
  "explain"          => "解説"
}

ITEM_LABEL = {
  "type"             => "種別",
  "item_rank"        => "アイテムランク",
  "name"             => "アイテム名",
  "alias"            => "ユーザが付与した別名",
  "physical_attack"  => "攻撃力",
  "magic_attack"     => "魔力",
  "physical_defense" => "物理防御力",
  "magic_defense"    => "魔法防御力",
  "hit"              => "命中修正",
  "action"           => "行動修正",
  "range"            => "射程",
  "timing"           => "タイミング",
  "target"           => "対象",
  "roll"             => "判定",
  "price"            => "価格",
  "function"         => "効果・解説",
  "tags"             => "タグ",
  "recipe"           => "レシピ",
  "prefix_function"  => "プレフィックスドアイテム効果"
}

PREFIXED_EFFECT_LABEL = {
  "rank"             => "マジックグレード",
  "name"             => "接頭語",
  "allow_tags"       => "対応タグ",
  "required_tag"     => "必須タグ",
  "function"         => "アイテム効果"
}

def get_api(api)
  uri = URI.parse(api)
  request = Net::HTTP::Get.new(uri.request_uri)
  request['Accept-Charset'] = 'euc-jp, utf-8'
  request['Accept-Language'] = 'ja, en'
  request['User-Agent'] = 'lhz2cvs ver-0.0.2'

  response = Net::HTTP.start(uri.host, uri.port) do |http|
    response = http.request(request)
    response.body.force_encoding('UTF-8')
  end

  return response
end

skill_data = get_api(SKILL_API)
item_data = get_api(ITEM_API)
prefix_data = get_api(PREFIXED_EFFECT_API)

skill_book = JSON.parse(skill_data)

SKILL_LABEL.each_key do |k|
  skill_book["skills"].each do |skill|
    skill[SKILL_LABEL[k]] = skill[k]
    skill.delete(k)
  end
end

csv_data = ""

# label
csv_data += skill_book["skills"].first.to_a.map{|i|i.first}.to_csv

skill_book["skills"].each do |skill|
  csv_data += skill.to_a.map{|i|i.last}.to_csv
end

open("skills.csv", "w+"){|f|f.print(csv_data)}

prefixed_book = JSON.parse(prefix_data)

PREFIXED_EFFECT_LABEL.each_key do |k|
  prefixed_book["prefixed_effects"].each do |prefixed|
    prefixed[PREFIXED_EFFECT_LABEL[k]] = prefixed[k]
    prefixed.delete(k)
  end
end

csv_data = ""

# label
csv_data += prefixed_book["prefixed_effects"].first.to_a.map{|i|i.first}.to_csv

prefixed_book["prefixed_effects"].each do |prefixed|
  csv_data += prefixed.to_a.map{|i|i.last}.to_csv
end

open("prefixed_effects.csv", "w+"){|f|f.print(csv_data)}

item_book = JSON.parse(item_data)

ITEM_LABEL.each_key do |k|
  item_book["items"].each do |item|
    item[ITEM_LABEL[k]] = item[k]
    item.delete(k)
  end
end

csv_data = ""

# label
csv_data += item_book["items"].first.to_a.map{|i|i.first}.to_csv

item_book["items"].each do |item|
  csv_data += item.to_a.map{|i|i.last}.to_csv
end

open("all_items.csv", "w+"){|f|f.print(csv_data)}

item_book = JSON.parse(item_data)

ITEM_LABEL.each_key do |k|
  item_book["items"].each do |item|
    item[ITEM_LABEL[k]] = item[k]
    item.delete(k)
  end
end

csv_data = ""

# label
csv_data += item_book["items"].first.to_a.map{|i|i.first}.to_csv
item_book["items"].select{|i| i["レシピ"] != nil }.each do |item|
  csv_data += item.to_a.map{|i|i.last}.to_csv
end

open("named_items.csv", "w+"){|f|f.print(csv_data)}

item_book = JSON.parse(item_data)

ITEM_LABEL.each_key do |k|
  item_book["items"].each do |item|
    item[ITEM_LABEL[k]] = item[k]
    item.delete(k)
  end
end

csv_data = ""

# label
csv_data += item_book["items"].first.to_a.map{|i|i.first}.to_csv
item_book["items"].reject{|i|
  i["レシピ"] != nil
}.select{|i|
  i["種別"].match(/(武器|防具|盾|補助)/)
}.each do |item|
  csv_data += item.to_a.map{|i|i.last}.to_csv
end

open("normal_wepon_and_armor.csv", "w+"){|f|f.print(csv_data)}

item_book = JSON.parse(item_data)

ITEM_LABEL.each_key do |k|
  item_book["items"].each do |item|
    item[ITEM_LABEL[k]] = item[k]
    item.delete(k)
  end
end

csv_data = ""

# label
csv_data += item_book["items"].first.to_a.map{|i|i.first}.to_csv
item_book["items"].reject{|i|
  i["レシピ"] != nil
}.reject{|i|
  i["種別"].match(/(武器|防具|盾|補助)/)
}.each do |item|
  csv_data += item.to_a.map{|i|i.last}.to_csv
end

open("normal_other_items.csv", "w+"){|f|f.print(csv_data)}

