SET ROLE mydba;
DROP FUNCTION py_foxess_api;
CREATE OR REPLACE FUNCTION "DEV".py_foxess_api(p_method character varying, p_key text, p_domain character varying, p_path character varying, p_param json DEFAULT '{"None": "None"}'::json)
 RETURNS text
 LANGUAGE plpython3u
AS $function$
    import json
    import time
    import urllib3
    import requests
    import hashlib

    class GetAuth:
        def get_signature(self, token, path, lang='en'):
            """
            This function is used to generate a signature consisting of URL, token, and timestamp, and return a dictionary containing the signature and other information.
            :param token: your key
            :param path:  your request path
            :param lang: language, default is English.
            :return: with authentication header
            """
            timestamp = round(time.time() * 1000)
            signature = fr'{path}\r\n{token}\r\n{timestamp}'

            result = {
                'token': token,
                'lang': lang,
                'timestamp': str(timestamp),
                'signature': self.md5c(text=signature),
                'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) '
                                'Chrome/117.0.0.0 Safari/537.36'
            }
            return result

        @staticmethod
        def md5c(text="", _type="lower"):
            res = hashlib.md5(text.encode(encoding='UTF-8')).hexdigest()
            if _type.__eq__("lower"):
                return res
            else:
                return res.upper()

    def fr_requests(method, key, domain, path, param):
        url = domain + path
        sleep_time = 0
        debug = False
        headers = GetAuth().get_signature(token=key, path=path)
        time.sleep(sleep_time)

        if method == 'get':
            response = requests.get(url=url, params=param, headers=headers, verify=False)
        elif method == 'post':
            response = requests.post(url=url, json=param, headers=headers, verify=False)
        else:
            raise Exception('request method error')

        return json.loads(response.content)['result']
    return fr_requests(p_method, p_key, p_domain, p_path, json.loads(p_param))

$function$
