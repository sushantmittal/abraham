# frozen_string_literal: true

module AbrahamHelper
  def abraham_tour
    # Do we have tours for this controller/action in the user's locale?
    tours = Rails.configuration.abraham.tours["#{controller_name}.#{action_name}.#{I18n.locale}"]

    tours ||= Rails.configuration.abraham.tours["#{controller_name}.#{action_name}.#{I18n.default_locale}"]

    if tours
      completed = AbrahamHistory.where(
        creator_id: current_user.id,
        controller_name: controller_name,
        action_name: action_name
      )
      remaining = tours.keys - completed.map(&:tour_name)

      if remaining.any?
        remaining.each do |tour_key|
          # Generate the javascript snippet for the next remaining tours
          render(partial: "application/abraham",
                 locals: { tour_name: tour_key,
                           steps: tours[tour_key]["steps"] })
        end
      end
    end
  end

  def abraham_cookie_prefix
    "abraham-#{Rails.application.class.parent.to_s.underscore}-#{current_user.id}-#{controller_name}-#{action_name}"
  end

  def abraham_domain
    request.host
  end
end
