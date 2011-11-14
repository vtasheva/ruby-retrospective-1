require 'bigdecimal'
require 'bigdecimal/util'

class Inventory
  attr_accessor :inventory

  def initialize
    @inventory = []
  end

  def register(name, price, promotion = {})
    new_product = Product.new(name, price, promotion)
    if @inventory.include? new_product
      raise "This product is already registered."
    end

    @inventory << new_product
  end

  def new_cart
    Cart.new inventory
  end
end

class Cart
  FRAMEWORK = "|------------------------------------------------|----------|\n"
  LINE = "+------------------------------------------------+----------+\n"
  ITEM_DEFINITION = "------------------------------------------------"
  PRICE_DEFINITION = "----------"

  attr_accessor :cart, :inventory

  def initialize(inventory)
    @cart = {}
    @inventory = inventory
  end

  def add(name, amount = 1)
    if !@inventory.select { |item| item.name == name }
      raise "This product does not exist in inventory."
    end

    if @cart.has_key? name
      add_existing_product name, amount
    else
      add_not_existing_product name, amount
    end
  end

  def total
    total = BigDecimal('')
    @cart.each do |key, amount|
      product = @inventory.select { |item| item.name == key }.first
      total += product.price * amount
      if product.promotion.has_key? :get_one_free
        total -= (amount / product.promotion[:get_one_free]) * product.price
      end
    end
    "%.2f" % total
  end

  def invoice
    items = get_items
    items_template = items.map { |product, value| process_item(product, value) }

    invoice_header << items_template.join << invoice_footer
  end

  private

  def get_items
    items = {}
    @cart.each do |key, amount|
      product = @inventory.select { |item| item.name == key}.first
      items[product.name] = product.price * amount
      if product.promotion.has_key? :get_one_free
        times = (amount / product.promotion[:get_one_free])
        items[product.name] -= times * product.price
      end
    end   
    items 
  end

  def add_existing_product(name, amount)
    if @cart[name] + amount <= 0 || @cart[name] + amount > 99
      raise "Not valid value for amount"
    end
    @cart[name] += amount
  end

  def add_not_existing_product(name, amount)
    if amount <= 0
      raise "Not valid value for amount"
    end
    @cart[name] = amount    
  end

  def process_item(product, v)
    line = ''

    price = "%.2f" % v.round(2)
    product_price = @cart[product].to_s
    exceed = product.length + product_price.length
    number_spaces = ITEM_DEFINITION.length - exceed
    spaces = " " * number_spaces
    line = FRAMEWORK.gsub(ITEM_DEFINITION, product + spaces + product_price)
    number_spaces = PRICE_DEFINITION.length - price.length
    line.gsub(PRICE_DEFINITION, " " * number_spaces + price)
  end

  def invoice_header
    result = LINE
    number_spaces = ITEM_DEFINITION.length - "Name".length - "qty".length
    spaces = " " * number_spaces
    line = FRAMEWORK.gsub(ITEM_DEFINITION, "Name" + spaces + "qty")

    number_spaces = PRICE_DEFINITION.length - "price".length
    line = line.gsub(PRICE_DEFINITION, " " * number_spaces + "price")
    result << line << LINE
  end

  def invoice_footer
    result = LINE
    price = total
    number_spaces = ITEM_DEFINITION.length - "TOTAL".length
    line = FRAMEWORK.gsub(ITEM_DEFINITION, "TOTAL" + " " * number_spaces)

    number_spaces = PRICE_DEFINITION.length - price.length
    line = line.gsub(PRICE_DEFINITION, " " * number_spaces + price)
    result << line << LINE
  end
end

class Product
  attr_accessor :name, :price, :promotion

  def initialize(name, price, promotion)
    if name.length > 40
      raise "Name cannot be longer than 40 symbols."
    end

    range = 0.01..999.99
    if !range.include? price.to_d
      raise "Price is not in the range 0.01..999.99"
    end

    @name, @price, @promotion = name, price.to_d, promotion
  end

  def ===(other)
    self.name == other.name
  end
end