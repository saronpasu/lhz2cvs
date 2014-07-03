#-*- encoding: utf-8 -*-
require 'json/pure'
require 'net/http'
require 'uri'
require 'csv'

# ARGV = "http://lhrpg.com/lhz/pc?id=13152"

API_PATH = "http://lhrpg.com/lhz/api/"

CHARACTER_LABELS = {
  "name"             => "プレーヤーキャラクター名",
  "character_rank"   => "キャラクターランク",
  "level"            => "レベル",
  "player_name"      => "プレイヤー名",
  "race"             => "種族",
  "archetype"        => "アーキ職業",
  "main_job"         => "メイン職業",
  "sub_job"          => "サブ職業",
  "gender"           => "性別",
  "tags"             => "人物タグ",
  "remarks"          => "説明",
  "max_hitpoint"     => "最大HP",
  "effect"           => "初期因果力",
  "action"           => "行動力",
  "move"             => "移動力",
  "range"            => "武器の射程",
  "heal_power"       => "回復力",
  "physical_attack"  => "攻撃力",
  "magic_attack"     => "魔力",
  "physical_defense" => "物理防御力",
  "magic_defense"    => "魔法防御力",
  "str_basic_value"  => "STR能力基本値",
  "dex_basic_value"  => "DEX能力基本値",
  "pow_basic_value"  => "POW能力基本値",
  "int_basic_value"  => "INT能力基本値",
  "str_value"        => "STR能力値",
  "dex_value"        => "DEX能力値",
  "pow_value"        => "POW能力値",
  "int_value"        => "INT能力値",
  "abl_motion"       => "運動値",
  "abl_durability"   => "耐久値",
  "abl_dismantle"    => "解除値",
  "abl_operate"      => "操作値",
  "abl_sense"        => "知覚値",
  "abl_negotiate"    => "交渉値",
  "abl_knowledge"    => "知識値",
  "abl_analyze"      => "解析値",
  "abl_avoid"        => "回避値",
  "abl_resist"       => "抵抗値",
  "abl_hit"          => "命中値",
  "creed_name"       => "ガイディングクリード：クリード名",
  "creed"            => "ガイディングクリード：信念",
  "creed_tag"        => "ガイディングクリード：人物タグ",
  "creed_detail"     => "ガイディングクリード：解説",
  "connections"      => "コネクション一覧",
  "unions"           => "ユニオン一覧",
  "hand1"            => "手スロットのアイテム１",
  "hand2"            => "手スロットのアイテム２",
  "armor"            => "防具スロットのアイテム",
  "support_item1"    => "補助装備スロットのアイテム１",
  "support_item2"    => "補助装備スロットのアイテム２",
  "support_item3"    => "補助装備スロットのアイテム３",
  "bag"              => "鞄スロットのアイテム",
  "items"            => "所持品スロットのアイテム一覧",
  "style_skill_name" => "選択中のスタイル特技名",
  "skills"           => "取得特技一覧",
  "image_url"        => "画像URL",
  "sheet_url"        => "キャラクターシートURL"
}

CONNECTION_LABEL = {
  "name"             => "人物名",
  "tags"             => "タグ",
  "detail"           => "関係"
}

UNION_LABEL = {
  "name"             => "ユニオン名",
  "tags"             => "タグ",
  "detail"           => "備考"
}

ITEM_LABEL = {
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

SKILL_LABEL = {
  "type"             => "種別",
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


#p ARGV
pcid = nil
pcid = ARGV[0] || nil
exit if pcid.nil?
pcid = pcid.match(/(\d+)/) ? $1 : nil
exit if pcid.nil?

uri = URI.parse(API_PATH+pcid+'.json')
request = Net::HTTP::Get.new(uri.request_uri)
request['Accept-Charset'] = 'euc-jp, utf-8'
request['Accept-Language'] = 'ja, en'
request['User-Agent'] = 'lhz2cvs ver-0.0.1'

response = Net::HTTP.start(uri.host, uri.port) do |http|
  response = http.request(request)
  response.body.force_encoding('UTF-8')
end


json = response
char_data = JSON.parse(json)

# p char_data

# name changes

CONNECTION_LABEL.each_key do |k|
  char_data["connections"].each do |connection|
    connection[CONNECTION_LABEL[k]] = connection[k]
    connection.delete(k)
  end
end

UNION_LABEL.each_key do |k|
  char_data["unions"].each do |union|
    union[UNION_LABEL[k]] = union[k]
    union.delete(k)
  end
end

ITEM_LABEL.each_key do |k|
  if char_data["hand1"] then
    char_data["hand1"][ITEM_LABEL[k]] = char_data["hand1"][k]
    char_data["hand1"].delete(k)
  end
  if char_data["hand2"] then
    char_data["hand2"][ITEM_LABEL[k]] = char_data["hand2"][k]
    char_data["hand2"].delete(k)
  end
  if char_data["armor"] then
    char_data["armor"][ITEM_LABEL[k]] = char_data["armor"][k]
    char_data["armor"].delete(k)
  end
  if char_data["support_item1"] then
    char_data["support_item1"][ITEM_LABEL[k]] = char_data["support_item1"][k]
    char_data["support_item1"].delete(k)
  end
  if char_data["support_item2"] then
    char_data["support_item2"][ITEM_LABEL[k]] = char_data["support_item2"][k]
    char_data["support_item2"].delete(k)
  end
  if char_data["support_item3"] then
    char_data["support_item3"][ITEM_LABEL[k]] = char_data["support_item3"][k]
    char_data["support_item3"].delete(k)
  end
  if char_data["bag"] then
    char_data["bag"][ITEM_LABEL[k]] = char_data["bag"][k]
    char_data["bag"].delete(k)
  end
  unless char_data["items"].empty? then
    char_data["items"].each do |item|
      unless item.nil? then
        item[ITEM_LABEL[k]] = item[k]
        item.delete(k)
      end
    end
  end
end

SKILL_LABEL.each_key do |k|
  char_data["skills"].each do |skill|
    skill[SKILL_LABEL[k]] = skill[k]
    skill.delete(k)
  end
end

CHARACTER_LABELS.each_key do |k|
  char_data[CHARACTER_LABELS[k]] = char_data[k]
  char_data.delete(k)
end

# p char_data

# to_csv

csv_data = ""
char_data.each_pair do |key, value|
  if [
    "プレーヤーキャラクター名",
    "キャラクターランク",
    "プレイヤー名",
    "種族",
    "アーキ職業",
    "メイン職業",
    "サブ職業",
    "性別",
  ].include?(key)
    csv_data += key.to_s + "," + value.to_s + "\n"
  end

  if [
    "人物タグ"
  ].include?(key)
    csv_data += key + "\n"
    csv_data += value.to_a.flatten.to_csv + "\n"
  end

  if [
    "説明"
  ].include?(key)
    csv_data += key + "\n"
    csv_data += "" + value  + "\n"
  end
end

char_data.each_pair do |key, value|
  unless [
    "プレーヤーキャラクター名",
    "キャラクターランク",
    "プレイヤー名",
    "種族",
    "アーキ職業",
    "メイン職業",
    "サブ職業",
    "性別",
    "人物タグ",
    "手スロットのアイテム１",
    "手スロットのアイテム２",
    "防具スロットのアイテム",
    "補助装備スロットのアイテム１",
    "補助装備スロットのアイテム２",
    "補助装備スロットのアイテム３",
    "鞄スロットのアイテム",
    "コネクション一覧",
    "ユニオン一覧",
    "所持品スロットのアイテム一覧",
    "取得特技一覧",
    "説明",
    "画像URL",
    "キャラクターシートURL",
    "取得中の特技スタイル",
  ].include?(key)
    csv_data += key + "," + value.to_s + "\n"
  end
end


char_data.each_pair do |key, value|
  if [
    "コネクション一覧",
    "ユニオン一覧",
  ].include?(key)
    csv_data += key + "\n"
    value.each do |v|
      csv_data += v.to_a.flatten.to_csv + "\n"
    end
  end



  if [
    "手スロットのアイテム１",
    "手スロットのアイテム２",
    "防具スロットのアイテム",
    "補助装備スロットのアイテム１",
    "補助装備スロットのアイテム２",
    "補助装備スロットのアイテム３",
    "鞄スロットのアイテム"
  ].include?(key)
    csv_data += key + "\n"
    csv_data += value.to_a.flatten.to_csv + "\n"
  end

  if [
    "所持品スロットのアイテム一覧",
  ].include?(key)
    csv_data += key + "\n"
    value.each do |v|
      csv_data += v.to_a.flatten.to_csv + "\n"
    end
  end

  if [
    "選択中のスタイル特技名",
  ].include?(key)
    csv_data += key.to_s + "," + value.to_s + "\n"
  end


  if [
    "取得特技一覧",
  ].include?(key)
    csv_data += key + "\n"
    value.each do |v|
      csv_data += v.to_a.flatten.to_csv + "\n"
    end
  end

  if [
    "画像URL",
    "キャラクターシートURL",
  ].include?(key)
    csv_data += key.to_s + "," + value.to_s + "\n"
  end

end

filename = "lhz_pc_"+pcid+".csv"

open(filename, 'w+'){|f|f.print(csv_data)}

