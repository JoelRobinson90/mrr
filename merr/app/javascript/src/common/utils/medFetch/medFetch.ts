const tempAuthToken = document.querySelector('meta[name=temp-auth-token]')?.getAttribute('content');

export const medFetch = (url: string): Promise<Response> => {
  if (tempAuthToken) {
    return fetch(url, {
      headers: new Headers({
        'X-Temp-Auth-Token': tempAuthToken,
      }),
    });
  } else {
    return fetch(url);
  }
};
