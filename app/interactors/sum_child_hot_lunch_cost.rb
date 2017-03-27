# == Context Input
#
# [+context.child+ [+Child+]]
class SumChildHotLunchCost
  include Interactor

  AGE_RANGE = 4..5

  before do
    context.charges ||= Hash.new { |h, v| h[v] = Money.empty }
  end

  def call
    context.charges[:lunch] +=
      if applicable?
        hot_lunch_costs.inject(Money.empty, :+)
      else
        Money.empty
      end

    context.cost_adjustments = context.child.cost_adjustments
  end

  private

  def applicable?
    AGE_RANGE.include?(context.child.age)
  end

  def hot_lunch_costs
    hot_lunch_on_campus_indexes.map do |index|
      UserVariable["hot_lunch_week_#{index}"]
    end
  end

  # @see Childcare#CHILDCARE_WEEKS
  def hot_lunch_on_campus_indexes
    on_campus_indexes =
      hot_lunch_start_dates.map do |index, date|
        index if context.child.on_campus_at?(date)
      end

    on_campus_indexes.compact
  end

  # @return [Hash<Integer,Date>]
  def hot_lunch_start_dates
    Hash[
      context.child.hot_lunch_weeks.map do |week_offset|
        [week_offset, UserVariable[:childcare_first_day] + week_offset.weeks]
      end
    ]
  end
end
