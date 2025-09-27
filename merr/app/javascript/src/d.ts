declare module '*.png' {
  const value: any;
  export = value;
}
declare module '*.svg' {
  const value: any;
  export = value;
}

type MedarriveGlobal = {
  activeJwt?: string;
  flash?: {
    notice?: string;
    alert?: string;
  };
};

interface Window {
  MedArrive?: MedarriveGlobal;
}
