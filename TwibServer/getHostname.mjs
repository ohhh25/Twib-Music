const getExternalIP = async () => {
  const response = await fetch('https://api.ipify.org?format=json');
  const data = await response.json();
  return data.ip;
}

const getHostname = {
  "local": process.env.HOSTNAME || "127.0.0.1",
  "public": await getExternalIP()
}

export default getHostname;
