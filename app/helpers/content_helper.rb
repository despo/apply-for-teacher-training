module ContentHelper
  def render_content_page(page_name)
    raw_content = File.read("app/views/content/#{page_name}.md")
    content_with_erb_tags_replaced = ApplicationController.renderer.render(inline: raw_content)
    @converted_markdown = GovukMarkdown.render(content_with_erb_tags_replaced).html_safe
    @page_name = page_name
    render 'rendered_markdown_template'
  end
end
