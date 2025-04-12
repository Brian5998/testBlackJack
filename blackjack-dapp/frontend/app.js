let provider, signer, contract;
const CONTRACT_ADDRESS = "PASTE_DEPLOYED_CONTRACT_ADDRESS_HERE";
const ABI = [/* ABI goes here */];

async function connectWallet() {
  provider = new ethers.providers.Web3Provider(window.ethereum);
  await provider.send("eth_requestAccounts", []);
  signer = provider.getSigner();
  contract = new ethers.Contract(CONTRACT_ADDRESS, ABI, signer);
  log("✅ Wallet connected");
}

async function startGame() {
  const tx = await contract.startGame({ value: ethers.utils.parseEther("0.01") });
  await tx.wait();
  log("🎲 Game started!");
}

async function hit() {
  const tx = await contract.hit();
  await tx.wait();
  log("🃏 Hit!");
}

async function stand() {
  const tx = await contract.stand();
  await tx.wait();
  log("🛑 Stand!");
}

function log(msg) {
  const output = document.getElementById("output");
  output.innerText += "\n" + msg;
}
