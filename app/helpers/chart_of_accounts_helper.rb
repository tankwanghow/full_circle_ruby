module ChartOfAccountsHelper

  def render_chart_of_account
    account_types = AccountType.includes(:accounts).order(:name)
    all_roots(account_types).map do |account_type|
      content_tag :ul do
        render_account_types account_type, account_types
      end
    end.join('').html_safe
  end

  def render_account_types account_type, account_types
      content_tag :li do
        check_box_tag('account_type_' + account_type.id.to_s, '1', checked: true) +
        content_tag(:span, '') +
        link_to(account_type.name, edit_account_type_path(account_type), 
          name: edit_account_type_path(account_type), class: "label #{account_type_label(account_type)}") +
        content_tag(:ul) do
          children(account_type, account_types).map do |child|
            render_account_types(child, account_types)
          end.join('').html_safe
        end.html_safe +
        render_accounts_for(account_type)
      end.gsub(/\<ul\>\<\/ul\>/, '').html_safe # gsub for clean up empty list
  end

  def render_accounts_for account_type
    if account_type.accounts.length > 0
      content_tag :ul, class: :account do
        account_type.accounts.order(:name1).map do |account|
          content_tag :li do
            link_to(account.name1, edit_account_path(account), 
              name: edit_account_path(account), class: "label #{account_label(account)}",
                    data: { parent_id: account_type.id })
          end
        end.join('').html_safe
      end
    else
      ''.html_safe
    end
  end

  def account_type_label rendering_account_type
    if @account_type == rendering_account_type
      'label-warning'
    else
      'label-info'
    end
  end

    def account_label rendering_account
    if @account == rendering_account
      'label-warning'
    else
      'label-success' if rendering_account.status == 'Active'
    end
  end

  def selected_account_type_id
    @account.try(:account_type).try(:id) || @account_type.try(:id)
  end

  # Start - Make rendering the account_types_tree faster, one query for the entire tree.

  def children account_type, account_types
    account_types.collect { |obj| obj.parent_id == account_type.id ? obj : nil }.compact
  end

  def all_roots account_types 
    account_types.collect { |obj| obj.parent_id == nil ? obj : nil }.compact
  end

  # End - Make rendering the account_types_tree faster, one query for the entire tree.

end
