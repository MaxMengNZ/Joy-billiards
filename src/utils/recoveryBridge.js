export function recoveryAppUrl(search, hash) {
  const query = new URLSearchParams(search);
  const fragment = new URLSearchParams(hash.replace(/^#/, ''));
  const get = key => query.get(key) || fragment.get(key);
  if (get('error') || get('error_description')) return null;
  if (get('type') && get('type') !== 'recovery') return null;
  const result = new URLSearchParams({ type: 'recovery' });
  if (get('token_hash')) result.set('token_hash', get('token_hash'));
  else if (get('code')) result.set('code', get('code'));
  else if (get('access_token') && get('refresh_token')) {
    result.set('access_token', get('access_token'));
    result.set('refresh_token', get('refresh_token'));
    return `joybilliardsapp:///reset-password#${result}`;
  } else return null;
  return `joybilliardsapp:///reset-password?${result}`;
}
