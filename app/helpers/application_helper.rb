module ApplicationHelper
  include Pagy::Frontend

  def sidemenu_link(title, path, key, **)
    link_to title, path, class: "list-group-item list-group-item-action #{@sidemenu_active == key ? 'active' : ''}", **
  end
end
