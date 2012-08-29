module ApplicationHelper

  def menu text, &block
    a_text = text.html_safe + content_tag(:b, nil, class: 'caret')
    child = block_given? ? capture(&block) : nil
    content_tag :li, class: 'dropdown' do
      content_tag(:a, a_text, class: 'dropdown-toggle', href: '#', data: { toggle: 'dropdown'}) +
      content_tag(:ul, child, class: 'dropdown-menu')
    end
  end

  def menu_child text, url
    content_tag :li do
      link_to text, url
    end
  end

  def link_to_index obj
    link_to 'Index', search_path(search: { terms: "@#{obj.class.name}" }), class: 'btn btn-info'
  end

end