module FilterHelper

  def search_filter(resource, classes: [])
    simple_form_for :search, url: resource + '_path' do |form|
      form.input :search, as: :search,
      class: "form-control me-2", placeholder: "Search",
      input_html: { data: { controller: 'search',
                        filter_target: "search",
                        action: 'keyup->filter#filter'}, name: 'term' }
    end
  end
end


