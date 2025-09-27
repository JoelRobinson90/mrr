export const generateOptions = (options, select) => {
  const formatString = select.replace(/_/g, ' ').replace(/\b\w/g, (s: string) => s.toUpperCase());
  return [
    { value: '', text: `${formatString}` },
    ...options.map((option) => {
      const { name } = option;
      return { value: name || option, text: name || option };
    }),
  ];
};
