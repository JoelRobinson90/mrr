import { filtersVar, GET_ALL_FILTERS } from '@/common/graphql/cache';
import { useQuery } from '@apollo/client';
import { find } from 'lodash';

function useFilters() {
  const { data: cachedFilters } = useQuery(GET_ALL_FILTERS);

  const updateFilter = (filterId: string, filterKey: string, filterValue: any) => {
    const existentFilter = find(cachedFilters?.filters || [], (f) => f.id === filterId && f.key === filterKey);
    let newFilters = cachedFilters?.filters?.length ? [...cachedFilters.filters] : [];
    if (existentFilter) {
      // update existent
      newFilters = [...cachedFilters?.filters].map((f) => {
        return {
          id: f.id,
          key: f.key,
          value: f.id === filterId && f.key === filterKey ? filterValue : f.value,
        };
      });
      filtersVar(newFilters);
    } else {
      // Create new filter
      newFilters.push({
        id: filterId,
        key: filterKey,
        value: filterValue,
      });
      filtersVar(newFilters);
    }
    localStorage.setItem('filters', JSON.stringify(newFilters));
  };

  const clearFilterByKey = (filterKey: string) => {
    const filters = filtersVar();
    const excludedFiltersByKey = filters.filter((f) => f.id !== filterKey);
    filtersVar(excludedFiltersByKey);
    localStorage.setItem('filters', JSON.stringify(excludedFiltersByKey));
  };

  const findFilter = (id, key) => find(cachedFilters?.filters, (f) => f.id === id && f.key === key);

  return {
    filters: cachedFilters?.filters,
    updateFilter,
    clearFilterByKey,
    findFilter,
  };
}

export const FILTERS_SCHEDULE_FILTER_ID = 'schedule';

export default useFilters;
