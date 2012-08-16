module ChartOfAccountsHelper

  def render_chart_of_account
    account_types = AccountType.includes(:accounts)
    all_roots(account_types).map do |account_type|
      content_tag :ul do
        render_account_types account_type, account_types
      end
    end.join('').html_safe
  end

  def render_account_types account_type, account_types
      content_tag :li do
        check_box_tag('account_type_' + account_type.id.to_s) +
        content_tag(:span, '') +
        label_tag('', account_type.name, class: 'label label-info account_type',
                  data: { url: edit_account_type_path(account_type), 
                          id: account_type.id, selected: params_select_is?(account_type) }) +
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
      content_tag :ul do
        account_type.accounts.map do |account|
          content_tag :li do
            link_to(account.name1, '#', class: 'label label-success account',
                    data: { url: edit_account_path(account), parent_id: account_type.id, selected: params_select_is?(account) })
          end
        end.join('').html_safe
      end
    else
      ''.html_safe
    end
  end

  def params_select_is? obj
    params[:klass] == obj.class.name && params[:id].to_i == obj.id
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
