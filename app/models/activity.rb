# Activity model for customisation & custom methods
class Activity < PublicActivity::Activity

  def action
    type, _action = key.split('.')
    I18n.t("activity.models.#{type}.actions.#{_action}")
  end
end
