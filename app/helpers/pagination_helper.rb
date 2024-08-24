module PaginationHelper

  def table_pagination(resource, classes: "row justify-content-center")
    content_tag(:div, class: classes) do
      paginate(resource)
    end
  end

end
