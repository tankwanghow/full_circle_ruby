module ApplicationHelper

  def render_flash
    a = ''
    flash.each do |name, msg|
      a << content_tag(:div, class: "alert alert-#{name}") do
        content_tag(:button, '&times;'.html_safe, class: 'close', data: { dismiss: 'alert' }) +  
        content_tag(:div, msg, id: "flash_#{name}") if msg.is_a?(String)
      end
    end
    flash.clear
    a.html_safe
  end

  def menu text, &block
    a_text = text.html_safe + content_tag(:b, nil, class: 'caret')
    child = block_given? ? capture(&block) : nil
    content_tag :li, class: 'dropdown' do
      content_tag(:a, a_text, class: 'dropdown-toggle', href: '#', 'data-skip-pjax' => true) +
      content_tag(:ul, child, class: 'dropdown-menu')
    end
  end

  def menu_child text, url, options={}
    content_tag :li do
      link_to text, url, options
    end
  end

  def link_to_searchable doc
    url = url_for(controller: doc.searchable_type.pluralize.underscore, action: :edit, id: doc.searchable_id)
    if doc.searchable_type == 'User'
      link_to doc.searchable_type, url, class: 'btn btn-info', 'data-skip-pjax' => true
    else
      link_to doc.searchable_type, url, class: 'btn btn-info'
    end
  end

  def link_to_index klass
    link_to 'Index', search_path(search: { terms: "@#{klass.name}" }), class: 'btn btn-info'
  end

  def link_to_print_buttons object
    url_options = { controller: object.class.name.underscore.pluralize, action: 'show', format: 'pdf', id: object.id }
    link_to("Print with Form", url_for(url_options), class: 'btn btn-success', target: '_blank', data: { 'skip-pjax' => true }) + ' ' +
    link_to("Print", url_for(url_options.merge(static_content: true)), class: 'btn btn-inverse', target: '_blank', data: { 'skip-pjax' => true })
  end

  def link_to_audits_log(object)
    link_to "Show Audits Log", audit_logs_path(klass: object.class.name, id: object.id), class: 'btn btn-info' if current_user.is_admin?
  end

  def link_to_edit_action_buttons object, journal_url
    [ link_to('Cancel', edit_polymorphic_path(object), class: 'btn btn-warning'),
      link_to('New', new_polymorphic_path(object.class), class: 'btn btn-info'),
      link_to_index(object.class),
      link_to_print_buttons(object),
      link_to('Journal Entries', journal_url, class: 'btn btn-info'),
      link_to_audits_log(object) ].join(' ').html_safe
  end

end
