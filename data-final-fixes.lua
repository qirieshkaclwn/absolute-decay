local spoil_ticks = settings.startup["absolute-decay-spoil-ticks"].value

-- Fallback definition of "spoilage" item if playing vanilla 2.0/2.1 without Space Age expansion
if not data.raw.item["spoilage"] then
  data:extend({
    {
      type = "item",
      name = "spoilage",
      icon = "__base__/graphics/icons/coal.png", -- fallback icon from base game
      icon_size = 64,
      subgroup = "raw-resource",
      order = "g[spoilage]",
      stack_size = 100
    }
  })
end

local item_types = {
  "item", "ammo", "armor", "gun", "capsule", "module", "tool",
  "spidertron-remote", "rail-planner", "repair-tool", "selection-tool",
  "item-with-entity-data", "item-with-tags", "item-with-label", "item-with-inventory"
}

-- Base resources that should always spoil into standard spoilage instead of processing ingredients
local base_resources = {
  ["iron-ore"] = true,
  ["copper-ore"] = true,
  ["coal"] = true,
  ["stone"] = true,
  ["wood"] = true,
  ["uranium-ore"] = true,
  ["calcite"] = true,
  ["tungsten-ore"] = true,
  ["holmium-ore"] = true,
  ["scrap"] = true,
  ["metallic-asteroid-chunk"] = true,
  ["carbonic-asteroid-chunk"] = true,
  ["oxidizer-asteroid-chunk"] = true,
  ["promethium-asteroid-chunk"] = true,
}

-- Check if an item is a valid item prototype
local function is_valid_item(name)
  for _, itype in ipairs(item_types) do
    if data.raw[itype] and data.raw[itype][name] then
      return true
    end
  end
  return false
end

-- Helper to find recipe for an item (either name matches recipe, or item is in recipe results)
local function find_recipe_for_item(item_name)
  local recipe = data.raw.recipe[item_name]
  if recipe 
     and recipe.category ~= "recycling" 
     and not recipe.name:find("recycling") 
     and not recipe.name:find("empty%-") then
    return recipe
  end

  for _, r in pairs(data.raw.recipe) do
    if r.category ~= "recycling" 
       and not r.name:find("recycling") 
       and not r.name:find("empty%-") then
      if r.result == item_name then
        return r
      elseif r.results then
        for _, res in ipairs(r.results) do
          if res.name == item_name or (type(res) == "table" and res[1] == item_name) then
            return r
          end
        end
      end
    end
  end
  return nil
end

local item_costs = {}
local processing = {}

-- Recursive cost calculation to determine item complexity
local function calculate_cost(item_name)
  if item_costs[item_name] then
    return item_costs[item_name]
  end
  if processing[item_name] then
    return 1 -- prevent infinite cycles
  end
  processing[item_name] = true

  local recipe = find_recipe_for_item(item_name)
  if not recipe then
    item_costs[item_name] = 1
    processing[item_name] = nil
    return 1
  end

  local ingredients = recipe.ingredients
  if not ingredients then
    ingredients = recipe.normal and recipe.normal.ingredients or recipe.expensive and recipe.expensive.ingredients
  end

  if not ingredients then
    item_costs[item_name] = 1
    processing[item_name] = nil
    return 1
  end

  local total_cost = 0
  for _, ing in ipairs(ingredients) do
    local ing_name
    local ing_amount = 1
    if type(ing) == "string" then
      ing_name = ing
    elseif ing.name then
      ing_name = ing.name
      ing_amount = ing.amount or 1
    elseif ing[1] then
      ing_name = ing[1]
      ing_amount = ing[2] or 1
    end

    if ing_name then
      total_cost = total_cost + ing_amount * calculate_cost(ing_name)
    end
  end

  item_costs[item_name] = total_cost > 0 and total_cost or 1
  processing[item_name] = nil
  return item_costs[item_name]
end

-- Find the most expensive ingredient that is a valid item (excluding fluids and the item itself)
local function get_most_expensive_ingredient(item_name)
  local recipe = find_recipe_for_item(item_name)
  if not recipe then return nil end

  local ingredients = recipe.ingredients
  if not ingredients then
    ingredients = recipe.normal and recipe.normal.ingredients or recipe.expensive and recipe.expensive.ingredients
  end

  if not ingredients then return nil end

  local max_cost = -1
  local expensive_ing = nil

  for _, ing in ipairs(ingredients) do
    local ing_name
    local ing_type = "item"
    if type(ing) == "string" then
      ing_name = ing
    elseif ing.name then
      ing_name = ing.name
      ing_type = ing.type or "item"
    elseif ing[1] then
      ing_name = ing[1]
    end

    if ing_name and ing_name ~= item_name and ing_type ~= "fluid" and is_valid_item(ing_name) then
      local cost = calculate_cost(ing_name)
      if cost > max_cost then
        max_cost = cost
        expensive_ing = ing_name
      end
    end
  end

  return expensive_ing
end

-- Apply spoilage to all items
for _, item_type in ipairs(item_types) do
  if data.raw[item_type] then
    for name, item in pairs(data.raw[item_type]) do
      -- Exclude "spoilage" itself, and blueprint/planner/deconstruction tools to prevent GUI issues
      if name ~= "spoilage"
         and not name:find("blueprint")
         and not name:find("deconstruction")
         and not name:find("upgrade") then
        
        -- Apply spoilage if the item does not already have a spoil_result
        if not item.spoil_result then
          local result = "spoilage"
          if not base_resources[name] then
            result = get_most_expensive_ingredient(name) or "spoilage"
          end
          item.spoil_result = result
          item.spoil_ticks = spoil_ticks
        end
      end
    end
  end
end
