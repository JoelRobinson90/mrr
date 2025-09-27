import React from 'react';

// Inlcude any global CSS imports here
import '@elastic/eui/dist/eui_theme_light.css';

export const parameters = {
  actions: { argTypesRegex: "^on[A-Z].*" },
}

// Use this to wrap global decorators around all stories
export const decorators = [
  (Story) => <div style={{margin: '1em'}}><Story /></div>
]
