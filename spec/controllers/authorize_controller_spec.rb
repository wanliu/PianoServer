describe AuthorizeController, type: :request do
  describe 'actions' do
    describe '#weixin_redirect_url' do
      it 'should create a new user' do
        client = WeixinClient.instance.client
        code = 'grand_code123'

        expect(client).to receive(:is_valid?).and_return(true)
        expect(client).to receive(:app_id).and_return('app_id')

        token_obj = double(result: {'access_token' => 'valid_access_token'})
        expect(client).to receive(:get_oauth_access_token).with(code).and_return(token_obj)

        access_token = token_obj.result['access_token']

        info = double(
          result: {
            'openid' => 'o0tInv8I0VvpdNyx12tMTy9asT-0',
            'nickname' => '羁绊',
            'sex' => 1,
            'language' => 'zh_CN',
            'city' => '太原',
            'province' => '山西',
            'country' => '中国',
            'headimgurl' => 'http://wx.qlogo.cn/mmopen/Ccnk8Z7hLeMQsChtJJugQ6ronzJsp31TeickDmOBAl2ibRnsgxP3KZpx9LSAGDefATebLVU1Op6wWNyFVXr9H9LBhic1Egws9zE/0',
            'privilege' => []
          }
        )
        expect(client).to receive(:get_oauth_userinfo).with('app_id', access_token).and_return(info)

        expect(User.exists?).to be false
        get '/authorize/weixin_redirect_url?', code: code
        expect(User.exists?).to be true
      end
    end
  end
end
