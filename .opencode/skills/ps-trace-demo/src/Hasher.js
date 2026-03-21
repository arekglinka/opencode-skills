export function nativeHash(str) {
  let hash = 2166136261;
  for (let i = 0; i < str.length; i++) {
    hash ^= str.charCodeAt(i);
    hash = Math.imul(hash, 16777619);
    hash = hash >>> 0;
  }
  return hash;
}

export function intToHex(n) {
  return (n >>> 0).toString(16);
}
