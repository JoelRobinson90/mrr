/* eslint-disable camelcase */
import { startCase } from 'lodash';

const formatVisitProviders = (providers) => providers?.map(({ first_name, last_name, role }) => ({
  name: `${first_name} ${last_name}`,
  label: startCase(role),
}));

export default formatVisitProviders;
