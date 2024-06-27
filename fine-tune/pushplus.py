import requests
import argparse
import json


def parse_args():
    parser = argparse.ArgumentParser()
    parser.add_argument("--title", type=str)
    parser.add_argument("--content", type=str)
    return parser.parse_args()


def main(args):
    token="5fb004d43df7437f8620ffb5d50f3118"
    
    url = 'http://www.pushplus.plus/send'
    
    data = {
        "token": token,
        "title": args.title if args.title else "AMRBART标题",
        "content": args.content if args.content else "AMRBART内容",
    }
    
    body = json.dumps(data).encode(encoding="utf-8")
    headers = {'Content-Type':'application/json'}
    requests.post(url,data=body,headers=headers)
    
if __name__ == "__main__":
    args = parse_args()
    main(args)



