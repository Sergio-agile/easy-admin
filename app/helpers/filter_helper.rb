module FilterHelper

  def search_filter(resource, classes: [])
    simple_form_for :search, url: resource + '_path' do |form|
      form.input :search, as: :search,
      class: "form-control me-2", placeholder: "Search",
      input_html: { value: params[:term] || '',
                    data: {
                      filter_target: "search",
                      action: 'keyup->filter#filter change->search#resetPage'}, name: 'term' }
    end
  end
end


