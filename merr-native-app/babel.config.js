module.exports = (api) => {
  api.cache(true);
  return {
    presets: ['babel-preset-expo'],
    plugins: [
      [
        'module-resolver',
        {
          extensions: [
            '.js',
            '.jsx',
            '.android.js',
            '.ios.js',
          ],
          root: ['./'],
          alias: {
            '@assets': './assets',
            '@': './src',
          },
        },
      ],
    ],
  };
};
