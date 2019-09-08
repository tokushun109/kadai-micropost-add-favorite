class User < ApplicationRecord
    before_save { self.email.downcase! }
    validates :name, presence: true, length: { maximum: 50 }
    validates :email, presence: true, length: { maximum: 255 },
                        format: { with: /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i },
                        uniqueness: { case_sensitve: false }
    has_secure_password
    
    has_many :microposts
    # フォローする一人に対してフォローされる多数を参照する関係
    has_many :relationships
    # followingsはrelationshipsを利用して、follow_idを参照する
    has_many :followings ,through: :relationships ,source: :follow
    # フォローされる一人に対してフォローする多数を参照する関係
    has_many :reverses_of_relationship, class_name: 'Relationship'
    # followesはreverses_of_relationshipを利用して、user_idを参照する
    has_many :followers ,through: :reverses_of_relationship ,source: :user
    
    # お気に入りする一人に対してお気に入りされる多数の投稿を参照する関係
    has_many :favorites
    has_many :fav_microposts ,through: :favorites ,source: :micropost

    def follow(other_user)
        # ①other_userは自分ではない
        # selfはメソッドを使用するuser自身
        # unless self == other_user
        
        # ②すでにフォローをしているか
        # メソッドを行うユーザー自身のid(user_id)が含まれるリレーションの中から、
        # follow_idにother_userのidが含まれているものがあるかを探す。
        # createは(build+save)
            self.relationships.find_or_create_by(follow_id: other_user.id)
        # end
    end
    def unfollow(other_user)
        # ①すでにフォローしているか
        # 値があればリレーションに値を入れる。なければnil。
        relationship = self.relationships.find_by(follow_id: other_user.id)
        # ②もしリレーションに値が入っているなら、リレーションの値を削除
        relationship.destroy if relationship
    end
    
    def following?(other_user)
        #メソッドを使うユーザーが、フォローしているユーザーの中（配列の中）で
        #other_userが入っているか。
        self.followings.include?(other_user)
    end
    
    def feed_microposts
        Micropost.where(user_id: self.following_ids + [self.id])
    end
        
    def favorite(fav_micropost)
    # お気に入りしようとするユーザーとお気に入りされる投稿をもつユーザーが違う場合
        unless self == fav_micropost.user
    # お気に入りの中から、
    # ①すでにお気に入りしているユーザーがある場合、そのお気に入りインスタンスを返す
    # ②お気に入りしているユーザーがない場合、新たにお気に入りインスタンスをさ作成し、セーブする
        self.favorites.find_or_create_by(micropost_id: fav_micropost.id)
        end
    end  
    
    # ユーザーがもつお気に入りの中から、
    # ①消そうとしているお気に入りの投稿と同じmicroposts_idをもつお気に入りインスタンスをfavoriteに代入
    # ②もし値が代入されていたら（nilじゃなければ）favorite を削除する
    def unfavorite(fav_micropost)
        favorite = self.favorites.find_by(micropost_id: fav_micropost.id)
        favorite.destroy if favorite
    end
        
    def favorite?(fav_micropost)
        self.fav_microposts.include?(fav_micropost)
    end
end