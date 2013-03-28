class DriverCommissionsController < ApplicationController

  def show
    new_results = []
    params[:options] ||= {}
    @headers = []
    @body = []
    @footers = []

    if params[:options]
      results = DriverCommission.new(params[:options]).results.hashes
      results.map do |r|
        new_results << commission_decider(r).calculate_commission(r, params[:options][:employee_tags])
      end
    end

    if new_results.count > 0
      @headers = header(new_results)
      @body = body(new_results)
      @footers = footer(new_results)
    end
  end

private

  def header hash_array
    hash_array.first.map { |k,v| k.humanize.titleize }
  end

  def body hash_array
    val =[]
    hash_array.each { |h| val << h.map { |k,v| v.to_s.split('|').join(' ') } }
    val
  end

  def footer hash_array
    val =[]
    unload_amount = 0.to_money
    load_amount = 0.to_money
    hash_array.each { |h| unload_amount += h['unload_pay'].to_money; load_amount += h['load_pay'].to_money; }
    val << [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, load_amount.format, unload_amount.format, nil]
  end

  def commission_decider row
    arys = (row['tags'].split('|') & %w(eggsalescomm eggtranscomm dungtransbagcomm dungtransloadcomm feedtranstonscomm traytranscomm))
    if arys.count > 1
      row[:status] = 'error'
    else
      decider arys[0]
    end
  end

  def decider klass
    case klass
    when 'eggsalescomm'
      EggSalesCommission
    when 'eggtranscomm'
      EggTransCommission
    when 'dungtransbagcomm'
      DungTransBagCommission
    when 'dungtransloadcomm'
      DungTransLoadCommission
    when 'feedtranstonscomm'
      FeedTransTonsCommission
    when 'traytranscomm'
      TrayTransCommission
    else
      NoCommission
    end
  end
end

class NoCommission
  def self.calculate_commission row, employee_tags
    row.merge!(load_pay: 0.to_money)
    row.merge!(unload_pay: 0.to_money)
    row.merge!(status: 'Not Found!')
  end
end

class Commission
  @less_5_customer_commission = 0
  @more_5_customer_commission = 0
  @loading_commission_percentage = 0
  @unloading_commission_percentage = 0

  def self.calculate_commission row, employee_tags
    row.merge!(load_pay: loaders_commission(row, employee_tags))
    row.merge!(unload_pay: unloaders_commission(row, employee_tags))
    row.merge!(status: 'OK')
  end

private

  def self.loaders_commission row, employee_tags
    handlers_commission(row, employee_tags, 'loader_tags', @loading_commission_percentage)
  end

  def self.unloaders_commission row, employee_tags
    handlers_commission(row, employee_tags, 'unloader_tags', @unloading_commission_percentage)
  end

  def self.handlers_commission row, employee_tags, handler_tags, percentage
    if has_commission?(row[handler_tags], employee_tags)
      row['qty'].to_money * commission(row['doc'].to_i, row['city']) * percentage / handlers_divider(row[handler_tags])
    else
      0.to_money
    end
  end

  def self.handlers_divider handlers
    handlers ? handlers.split('|').compact.count : 0
  end

  def self.has_commission? handlers, employee_tags
    a = handlers ? handlers.split('|').compact : []
    e = employee_tags ? employee_tags.split(',').compact : []
    a.include?(e.map { |t| t.strip }.first) ? true : false
  end

  def self.commission customers_count, city
    customers_count > 5 ? @more_5_customer_commission : @less_5_customer_commission
  end

end

class EggTransCommission < Commission
  @less_5_customer_commission = 0.03 / 30
  @more_5_customer_commission = 0.03 / 30
  @loading_commission_percentage = 0.4
  @unloading_commission_percentage = 0.6

  def self.commission customers_count, city
    return @less_5_customer_commission if city.downcase == 'kampar'
    customers_count > 5 ? @more_5_customer_commission : @less_5_customer_commission
  end
end

class EggSalesCommission < Commission
  @less_5_customer_commission = 0.12 / 30
  @more_5_customer_commission = 0.12 / 30
  @loading_commission_percentage = 0.4
  @unloading_commission_percentage = 0.6
end

class DungTransBagCommission < Commission
  @less_5_customer_commission = 0.1
  @more_5_customer_commission = 0.1
  @loading_commission_percentage = 0.5
  @unloading_commission_percentage = 0.5
end

class DungTransLoadCommission < Commission
  @less_5_customer_commission = 10
  @more_5_customer_commission = 10
  @loading_commission_percentage = 0.5
  @unloading_commission_percentage = 0.5

  def self.handlers_commission row, employee_tags, handler_tags, percentage
    if has_commission?(row[handler_tags], employee_tags)
      row['doc'].to_i * commission(row['doc'].to_i) * percentage / handlers_divider(row[handler_tags])
    else
      0.to_money
    end
  end
end

class FeedTransTonsCommission < Commission
  @less_5_customer_commission = 3.5
  @more_5_customer_commission = 3.5
  @loading_commission_percentage = 0.5
  @unloading_commission_percentage = 0.5
end

class TrayTransCommission < Commission
  @less_5_customer_commission = 0.1 / 140
  @more_5_customer_commission = 0.1 / 140
  @loading_commission_percentage = 0.5
  @unloading_commission_percentage = 0.5
end