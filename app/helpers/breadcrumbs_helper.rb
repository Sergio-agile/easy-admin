module BreadcrumbsHelper

  def breadcrumb_list(&)
    content_tag 'ol', class: 'breadcrumb' do
      home_breadcrumb = breadcrumb_item 'home', root_path
      home_breadcrumb.to_s + capture(&)
    end
  end

  def breadcrumb_item(key = nil, path = nil, icon: nil, id: nil)
    title = key if key.is_a?(String)

    content_tag('li', class: 'breadcrumb-item', id:) do
      if path
        link_to title, path
      elsif block_given?
        yield
      else
        content_tag :span, title
      end
    end
  end

end
