require 'rails_helper'
require 'byebug'

RSpec.describe 'Posts', type: :request do
  describe 'GET /posts' do
    before { get '/posts' }

    it 'should return Ok' do
      payload = JSON.parse(response.body)
      expect(payload).to be_empty
      expect(response).to have_http_status(200)
    end

    describe 'with data in DB' do
      let!(:posts) { create_list(:post, 10, published: true) }

      it 'should return all published Posts' do
        get '/posts'
        payload = JSON.parse(response.body)

        expect(payload.size).to eq(posts.size)
        expect(response).to have_http_status(200)
      end
    end
  end

  describe 'GET /posts/{id}' do
    let!(:post) { create(:post) }

    it 'should return a post' do
      get "/posts/#{post.id}"
      payload = JSON.parse(response.body)

      expect(payload).to_not be_empty
      expect(payload['id']).to eq(post.id)
      expect(payload['title']).to eq(post.title)
      expect(payload['content']).to eq(post.content)
      expect(payload['published']).to eq(post.published)
      expect(payload['author']['name']).to eq(post.user.name)
      expect(payload['author']['email']).to eq(post.user.email)
      expect(payload['author']['id']).to eq(post.user.id)
      expect(response).to have_http_status(200)
    end
  end

  describe 'POST /posts' do
    let!(:user) { create :user }

    it 'should create a post' do

      req_payload = {
        post: {
          title: 'TEST',
          content: 'TEST CONTENT',
          published: false,
          user_id: 1
        }
      }

      post '/posts', params: req_payload
      payload = JSON.parse(response.body)

      expect(payload).to_not be_empty
      expect(payload['id']).to_not be_nil
      expect(response).to have_http_status(:created)
    end

    it 'should return error message on invalid post' do

      req_payload = {
        post: {
          content: 'TEST CONTENT',
          published: false,
          user_id: 1
        }
      }

      post '/posts', params: req_payload
      payload = JSON.parse(response.body)

      expect(payload).to_not be_empty
      expect(payload['error']).to_not be_empty
      expect(payload['status']).to eq('unprocessable_entity')
    end
  end

  describe 'PUT /posts' do
    let!(:article) { create :post }

    it 'should create a post' do

      req_payload = {
        post: {
          title: 'TEST',
          content: 'TEST CONTENT',
          published: false,
          user_id: 1
        }
      }

      put "/posts/#{article.id}", params: req_payload
      payload = JSON.parse(response.body)

      expect(payload).to_not be_empty
      expect(payload['id']).to eq(article.id)
      expect(response).to have_http_status(:ok)
    end

    it 'should return error message on invalid post' do

      req_payload = {
        post: {
          title: nil,
          content: nil,
          user_id: 1
        }
      }

      put "/posts/#{article.id}", params: req_payload
      payload = JSON.parse(response.body)
      # byebug
      expect(payload).to_not be_empty
      expect(payload['error']).to_not be_empty
      expect(payload['status']).to eq('unprocessable_entity')
    end
  end
end