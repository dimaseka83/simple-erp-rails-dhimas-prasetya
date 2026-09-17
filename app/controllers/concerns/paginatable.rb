# Plain LIMIT/OFFSET windowing for index pages — not a Manager concern
# (it's a read, not business logic or a write), just controller plumbing
# shared across table pages per design.md's "Pagination sederhana bawah".
module Paginatable
  extend ActiveSupport::Concern

  PER_PAGE = 20

  private
    def paginate(relation)
      page = [ params[:page].to_i, 1 ].max
      total_count = relation.count
      total_pages = [ (total_count.to_f / PER_PAGE).ceil, 1 ].max

      @pagination = { page: page, total_pages: total_pages, total_count: total_count }
      relation.limit(PER_PAGE).offset((page - 1) * PER_PAGE)
    end
end
