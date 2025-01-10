# update this to call some homelab AI agent that
# can give you a reminder about your life =)
function fish_greeting
	set choices "Howdy, partner!"\
		"What’s cookin', good lookin'?"\
		"Yo, yo, yo!"\
		"What’s the buzz, cuz?"\
		"Sup, buttercup?"\
		"Hello, sunshine!"\
		"Ahoy, matey!"\
		"Ahoy there, sea dog!"\
		"Hey, hey, hey!"\
		"What’s shakin', bacon?"\
		"Yo, ho, ho!"\
		"And a bottle of 'hello!'"\
		"Knock knock!"\
		"Who’s there? It's me!"\
		"Greetings, Earthling!"\
		"Take me to your leader."\
		"Hello, sunshine!"\
		"I’ve been waiting for you, starlight!"\
		"Hey there, sugarplum!"\
		"I’m sweeter than candy!"\
		"Well, well, well!"\
		"Look who it is!"\
		"What's up, doc?"\
		"Rabbit season!"\
		"Good day, mate!"\
		"Crikey, it’s good to see you!"\
		"Ahoy!"\
		"Is it me you’re looking for?"\
		"Hello, you magnificent creature!"\
		"Are you made of copper and tellurium? Because you’re Cu-Te!"\
		"Salutations!"\
		"I come in peace… mostly."\
		"What’s the word, hummingbird?"\
		"Fly on in!"\
		"Good morrow!"\
		"How goes it?"\
		"Yo, bro!"\
		"How’s it hanging, man?"\
		"Hi there!"\
		"Long time, no see!"\
		"Greetings, mortal!"\
		"Prepare to be amazed!"\
		"Well, if it isn’t my favorite human!"\
		"What’s the story, morning glory?"\
		"Hey, cool cat!"\
		"How’s life in the fast lane?"\
		"What's cooking, good looking?"\
		"Can I get a side of awesome?"\
		"Hola, amigo!"\
		"What’s the vibe today?"\
		"What's poppin’, lockin’?"\
		"Can’t stop the groovin’!"\
		"Greetings from the other side!"\
		"I’ve come to steal your Wi-Fi."\
		"Hey, stranger!"\
		"Still strange, I see!"\
		"Yo, fam!"\
		"What's the deal, banana peel?"\
		"Howdy doo!"\
		"Here comes the boom!"\
		"Well, if it isn’t the one and only!"\
		"I’ve been waiting for this!"\
		"Bonjour, mon ami!"\
		"Ça va?"\
		"Sup, champ?"\
		"Ready to conquer the world?"\
		"What's up, cupcake?"\
		"You sweet thing!"\
		"Yo, wizard!"\
		"Got any spells for me today?"\
		"Hello, beautiful people!"\
		"I have arrived!"\
		"Sup, giraffe?"\
		"Got a tall tale?"\
		"Good day, sir!"\
		"A fine day to you as well, my friend!"\
		"Greetings, legend!"\
		"The tales of your awesomeness proceed you."\
		"Yo, peep this!"\
		"It's your favorite human here!"\
		"How’s life on the other side?"\
		"Better now, I hope!"\
		"Hello, you dazzling diamond!"\
		"You're sparkling brighter than usual!"\
		"Yo, chef!"\
		"What’s cooking good lookin’?"\
		"Hey, pal!"\
		"Who’s your buddy? I’m your buddy!"\
		"Howdy, partner!"\
		"Let’s rustle up some trouble."\
		"Hello, space cowboy!"\
		"Ready to ride into the sunset?"\
		"What's up, muffin?"\
		"You’re sweet as sugar!"\
		"Hey, friend!"\
		"Got room for one more?"\
		"Salutations, fellow human!"\
		"You come in peace?"\
		"How goes it, pumpkin?"\
		"Ready to be spiced up?"\
		"Yo, sunshine!"\
		"Shine on, you crazy diamond!"\
		"Hey, homie!"\
		"Ready for some shenanigans?"\
		"Hi, cutie pie!"\
		"Are you a pie? Because you’re sweet!"\
		"Hey, rockstar!"\
		"Got any new tunes?"\
		"What's the dealio, CEO?"\
		"Running the world today?"\
		"Hey, superstar!"\
		"Are you famous yet?"\
		"Greetings, maestro!"\
		"Let’s make some magic!"\
		"What's the vibe, tribe?"\
		"Let’s get it, fam!"\
		"Yo, panda!"\
		"Ready to nap and snack?"\
		"Ahoy, sailor!"\
		"Ready to set sail?"\
		"Yo, queen!"\
		"I bow down to your awesomeness."\
		"Good to see you, my fellow legend!"\
		"Let’s do legendary things!"\
		"Hey, broseph!"\
		"How’s life in the chill lane?"\
		"Yo, sunshine!"\
		"Feel that warmth? It’s me!"\
		"How’s it going, ninja?"\
		"I see you creeping!"\
		"Hello, my favorite!"\
		"Did you miss me?"\
		"Hey, champ!"\
		"Ready to crush it today?"\
		"What's up, cupcake?"\
		"You’re icing on the cake!"\
		"Hey, superstar!"\
		"No one shines brighter!"\
		"Yo, big cheese!"\
		"Meltin' into greatness!"\
		"Well, look who’s back!"\
		"Let the fun begin!"\
		"Hey, hero!"\
		"Got a cape today?"\
		"Yo, smarty pants!"\
		"Got any wisdom to drop?"\
		"Hey, pal!"\
		"Let’s go on an adventure!"\
		"Yo, legend!"\
		"Ready to add another chapter?"\
		"What's up, genius?"\
		"Show me the brilliance!"\
		"Hello, magnificent!"\
		"How does one do greatness today?"\
		"Yo, savage!"\
		"Ready to take over the world?"\
		"Hey, buddy!"\
		"Got some mischief planned?"\
		"Hello, visionary!"\
		"Got any big ideas?"\
		"Hey, genius!"\
		"Teach me something new!"\
		"Sup, wizard?"\
		"Got any magic today?"\
		"Yo, sport!"\
		"How’s the game of life treating you?"\
		"What's up, rockstar?"\
		"Ready to take the stage?"\
		"Hello, human!"\
		"Or should I say… legend?"\
		"Yo, rebel!"\
		"Let’s break some rules!"\
		"Hey, king!"\
		"You rule this day!"\
		"What's up, unicorn?"\
		"You magical creature!"\
		"Howdy, stranger!"\
		"Welcome to my world!"\
		"Hello, wild child!"\
		"Let’s cause some chaos!"\
		"Hey, rockstar!"\
		"The world is your stage!"\
		"Yo, champ!"\
		"Time to bring your A-game!"\
		"What's the haps, chap?"\
		"Ready for adventure?"\
		"Yo, wizard!"\
		"Got any potions?"\
		"Hey, cookie!"\
		"Ready to crumble?"\
		"Hello, mischief maker!"\
		"Got trouble brewing?"\
		"Yo, dynamo!"\
		"Time to light it up!"\
		"Hey, tiger!"\
		"You ready to pounce?"\
		"What's up, partner?"\
		"Let's kick it into high gear!"\
		"Yo, champion!"\
		"Let’s get it done!"
    random choice $choices
end
