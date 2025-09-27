import { getUpdatedQueryPath } from '@/common/utils/queries/queries';
import { useMemo } from 'react';

export type PaginationParams = {
  current_page: number;
  total_pages: number;
  rows_per_page: number;
};

export type UsePaginationReturn = {
  perPage: number;
  pageCount: number;
  activePage: number;
  onPageClick: (page: number, perPage: number) => void;
};

export const usePagination = ({ current_page, total_pages, rows_per_page }: PaginationParams): UsePaginationReturn =>
  useMemo<UsePaginationReturn>(
    () => ({
      perPage: rows_per_page,
      pageCount: total_pages,
      activePage: current_page,
      onPageClick: (page, rows_per_page) => {
        const newPath = getUpdatedQueryPath({ page, rows_per_page });
        window.location.assign(newPath);
      },
    }),
    [current_page, total_pages, rows_per_page],
  );
