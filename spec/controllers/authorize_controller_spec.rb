describe AuthorizeController, type: :request do
  describe 'actions' do
    describe '#weixin_redirect_url' do
      it 'should create a new user if not exist' do
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

        get '/authorize/weixin_redirect_url?', {code: code}, {'HTTP_REFERER' => root_url}

        expect(User.first.weixin_openid).to eq 'o0tInv8I0VvpdNyx12tMTy9asT-0'
        expect(User.first.nickname).to eq '羁绊'
        expect(User.first.sex).to eq '男'
        expect(User.first.language).to eq 'zh_CN'
        expect(User.first.city).to eq '太原'
        expect(User.first.province).to eq '山西'
        expect(User.first.country).to eq '中国'
        expect(User.first.image_url).to eq 'http://wx.qlogo.cn/mmopen/Ccnk8Z7hLeMQsChtJJugQ6ronzJsp31TeickDmOBAl2ibRnsgxP3KZpx9LSAGDefATebLVU1Op6wWNyFVXr9H9LBhic1Egws9zE/0!avatar'
        expect(User.first.weixin_privilege).to eq []
      end

      it 'will login in as current_user if this user exist' do
        client = WeixinClient.instance.client
        code = 'grand_code123'

        expect(client).to receive(:is_valid?).and_return(true)
        expect(client).to receive(:app_id).and_return('app_id')

        token_obj = double(result: {'access_token' => 'valid_access_token'})
        expect(client).to receive(:get_oauth_access_token).with(code).and_return(token_obj)

        access_token = token_obj.result['access_token']

        info = double(
          result: {
            'openid' => 'o0tInv8I0VvpdNyx12tMTy9asT-1',
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

        User.create(
          username: 'username',
          nickname: 'nickname',
          email: 'username@wanliu.biz',
          password: '12345678',
          image: 'http://some_valid_url/1.png',
          weixin_openid: 'o0tInv8I0VvpdNyx12tMTy9asT-1'
        )
        expect(User.count).to eq 1
        expect(User.first.username).to eq 'username'

        get '/authorize/weixin_redirect_url?', {code: code}, {'HTTP_REFERER' => root_url }
        expect(User.count).to eq 1
        expect(User.first.weixin_openid).to eq 'o0tInv8I0VvpdNyx12tMTy9asT-1'
        expect(User.first.nickname).to eq 'nickname'
      end
    end
  end
end
