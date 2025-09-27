const startCase = (string) => string.replace(
  /\w\S*/g,
  (txt) => txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase(),
);

export default startCase;
