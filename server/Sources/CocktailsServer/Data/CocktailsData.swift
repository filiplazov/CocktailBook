import Foundation
import CocktailsModels

struct CocktailsData {
    static let cocktails: [Cocktail] = [
        Cocktail(
            id: "0",
            name: "Piña colada",
            type: .alcoholic,
            shortDescription: "Velvety-smooth texture and a taste of the tropics are what this tropical drink delivers.",
            longDescription: "The Piña Colada is a Puerto Rican rum drink made with pineapple juice (the name means \"strained pineapple\" in Spanish) and cream of coconut. By most accounts, the modern-day Piña Colada seems to have originated from a 1954 version that bartender named Ramón \"Monchito\" Marrero Perez shook up at The Caribe Hilton hotel in San Juan, Puerto Rico. While you may not be sipping this icy-cold tiki drink on the beaches of Puerto Rico, it's sure to get you in a sunny mood no matter the season.",
            preparationMinutes: 7,
            imageName: "pinacolada",
            ingredients: [
                Ingredient(imperialAmount: "4 oz", name: "rum", metricAmount: "120 ml"),
                Ingredient(imperialAmount: "3 oz", name: "fresh pineapple juice, chilled (or use frozen pineapple chunks for a smoothie-like texture)", metricAmount: "90 ml"),
                Ingredient(imperialAmount: "2 oz", name: "cream of coconut (or use a combination of sweetened coconut cream and coconut milk)", metricAmount: "60 ml"),
                Ingredient(imperialAmount: "1 oz", name: "freshly squeezed lime juice (optional)", metricAmount: "30 ml"),
                Ingredient(imperialAmount: "2 cups", name: "ice", metricAmount: "480 ml"),
                Ingredient(imperialAmount: "", name: "Fresh pineapple, for garnish", metricAmount: "")
            ]
        ),
        Cocktail(
            id: "1",
            name: "Mojito",
            type: .alcoholic,
            shortDescription: "A refreshing Cuban classic made with white rum and muddled fresh mint.",
            longDescription: "This is an authentic recipe for mojito. I sized the recipe for one serving, but you can adjust it accordingly and make a pitcher full. It's a very refreshing drink for hot summer days. Be careful when drinking it, however. If you make a pitcher you might be tempted to drink the whole thing yourself, and you just might find yourself talking Spanish in no time! Tonic water can be substituted instead of the soda water but the taste is different and somewhat bitter.",
            preparationMinutes: 10,
            imageName: "mojito",
            ingredients: [
                Ingredient(imperialAmount: "10", name: "fresh mint leaves", metricAmount: "10"),
                Ingredient(imperialAmount: "½", name: "lime, cut into 4 wedges", metricAmount: "½"),
                Ingredient(imperialAmount: "2 tablespoons", name: "white sugar, or to taste", metricAmount: "30 ml"),
                Ingredient(imperialAmount: "1 cup", name: "ice cubes", metricAmount: "240 ml"),
                Ingredient(imperialAmount: "1 ½ fluid ounces", name: "white rum", metricAmount: "45 ml"),
                Ingredient(imperialAmount: "½ cup", name: "club soda", metricAmount: "120 ml")
            ]
        ),
        Cocktail(
            id: "2",
            name: "Daiquiri",
            type: .alcoholic,
            shortDescription: "An easy rum and lime-juice cocktail shaken over lots of ice, like an island margarita.",
            longDescription: "The original daiquiri is an extremely simple recipe that requires just three common ingredients. It is also one of the freshest drinks you can make and an essential rum cocktail everyone should know and taste. \r\nFor the best daiquiri, use quality ingredients, including premium rum, fresh lime juice, and homemade simple syrup. A well-made daiquiri should have a nice balance of sweet and sour and can be adjusted to your personal taste. Once you find your ideal mix, you will become a believer that those sugary-tart bottled daiquiris have no place in the bar.",
            preparationMinutes: 5,
            imageName: "daiquiri",
            ingredients: [
                Ingredient(imperialAmount: "1 ½ fluid ounces", name: "light rum", metricAmount: "45 ml"),
                Ingredient(imperialAmount: "1 fluid ounce", name: "lime juice", metricAmount: "30 ml"),
                Ingredient(imperialAmount: "1 teaspoon", name: "simple syrup", metricAmount: "5 ml"),
                Ingredient(imperialAmount: "1 cup", name: "ice", metricAmount: "240 ml")
            ]
        ),
        Cocktail(
            id: "3",
            name: "Manhattan",
            type: .alcoholic,
            shortDescription: "A classic cocktail made with whiskey, sweet vermouth, and bitters.",
            longDescription: "While rye is the traditional whiskey of choice, other commonly used whiskies include Canadian whisky, bourbon, blended whiskey, and Tennessee whiskey. The cocktail is usually stirred then strained into a cocktail glass and garnished traditionally with a maraschino cherry. A Manhattan may also be served on the rocks in a lowball glass.",
            preparationMinutes: 5,
            imageName: "manhattan",
            ingredients: [
                Ingredient(imperialAmount: "2 fluid ounces", name: "rye whiskey", metricAmount: "60 ml"),
                Ingredient(imperialAmount: "½ fluid ounce", name: "sweet vermouth", metricAmount: "15 ml"),
                Ingredient(imperialAmount: "1 dash", name: "Angostura bitters", metricAmount: "1 dash"),
                Ingredient(imperialAmount: "1 cup", name: "ice cubes", metricAmount: "240 ml"),
                Ingredient(imperialAmount: "1", name: "maraschino cherry", metricAmount: "1")
            ]
        ),
        Cocktail(
            id: "4",
            name: "Virgin Mixed Berry Caipirinha",
            type: .nonAlcoholic,
            shortDescription: "The Brazilian caipirinha is a cocktail that's hard to resist, but this virgin version might just be the perfect thing for you to drink.",
            longDescription: "A non-alcohol mixed berry Caipirinha is a wonderful mixture of fresh and juicy mixed berries like raspberry, strawberry and blueberry, muddled with lime and mint, bubbling with sweetness. It makes you feel light and refreshes on warm days and it's dead easy to prepare.",
            preparationMinutes: 8,
            imageName: "virginBerryCaipirinha",
            ingredients: [
                Ingredient(imperialAmount: "300 g", name: "fresh mixed berries", metricAmount: "300 g"),
                Ingredient(imperialAmount: "4", name: "Lime cut and halved", metricAmount: "4"),
                Ingredient(imperialAmount: "4 tbsp.", name: "mint leaves roughly torn", metricAmount: "60 ml"),
                Ingredient(imperialAmount: "8 tbsp.", name: "light brown soft sugar", metricAmount: "120 ml"),
                Ingredient(imperialAmount: "600 ml", name: "cream soda", metricAmount: "600 ml"),
                Ingredient(imperialAmount: "", name: "crushed ice", metricAmount: "")
            ]
        ),
        Cocktail(
            id: "5",
            name: "Basil Lemonade Punch",
            type: .nonAlcoholic,
            shortDescription: "Dress up your lemonade with this elegant take on a classic.",
            longDescription: "Bright fresh basil is muddled with sugar, then topped with lemonade and sparkly seltzer water for a bright non-alcoholic cocktail you can make in minutes. I don't have to convince you that lemonade is a brilliant option for a party libation, but I do want to heavily suggest you try it with this extra-fresh twist.",
            preparationMinutes: 6,
            imageName: "basilLemonadePunch",
            ingredients: [
                Ingredient(imperialAmount: "1 cup", name: "fresh basil leaves, loosely packed and coarsely chopped", metricAmount: "240 ml"),
                Ingredient(imperialAmount: "¼ cup", name: "sugar", metricAmount: "60 ml"),
                Ingredient(imperialAmount: "3 cups", name: "prepared lemonade", metricAmount: "720 ml"),
                Ingredient(imperialAmount: "3 cups", name: "seltzer water", metricAmount: "720 ml"),
                Ingredient(imperialAmount: "1", name: "lemon, sliced", metricAmount: "1"),
                Ingredient(imperialAmount: "", name: "crushed ice", metricAmount: "")
            ]
        ),
        Cocktail(
            id: "6",
            name: "Gin and tonic",
            type: .alcoholic,
            shortDescription: "The good 'ol G&T is a dead-simple summer drink, and another good reason to stay stocked up on fresh limes.",
            longDescription: "A gin and tonic or, less frequently, gin tonic, is a highball cocktail made with gin and tonic water poured over a large amount of ice. The ratio of gin to tonic varies according to taste, strength of the gin, other drink mixers being added, etc., with most recipes calling for a ratio between 1:1 and 1:3.",
            preparationMinutes: 3,
            imageName: "ginAndTonic",
            ingredients: [
                Ingredient(imperialAmount: "4 cubes", name: "ice", metricAmount: "4 cubes"),
                Ingredient(imperialAmount: "2 fluid ounces", name: "gin", metricAmount: "60 ml"),
                Ingredient(imperialAmount: "4 fluid ounces", name: "tonic water", metricAmount: "120 ml"),
                Ingredient(imperialAmount: "1 tablespoon", name: "fresh lime juice", metricAmount: "15 ml"),
                Ingredient(imperialAmount: "1", name: "lime wedge", metricAmount: "1")
            ]
        ),
        Cocktail(
            id: "7",
            name: "Margarita",
            type: .alcoholic,
            shortDescription: "A sweet tequila-based party drink that's easy to make in batches.",
            longDescription: "A margarita is a cocktail consisting of tequila, orange liqueur, and lime juice often served with salt on the rim of the glass. The drink is served shaken with ice, blended with ice, or without ice.",
            preparationMinutes: 5,
            imageName: "margarita",
            ingredients: [
                Ingredient(imperialAmount: "1 (6 ounce) can", name: "frozen limeade concentrate", metricAmount: "1 (180 ml) can"),
                Ingredient(imperialAmount: "6 fluid ounces", name: "tequila", metricAmount: "180 ml"),
                Ingredient(imperialAmount: "2 fluid ounces", name: "triple sec", metricAmount: "60 ml")
            ]
        ),
        Cocktail(
            id: "8",
            name: "Bloody Mary",
            type: .alcoholic,
            shortDescription: "This lively eye-opener adds a spicy kick to brunch.",
            longDescription: "In a cocktail mixer full of ice, combine the vodka, vegetable juice, Worcestershire sauce, hot pepper sauce, salt and pepper. Shake vigorously and strain into the glass. Garnish with a stalk of celery and olives stuck onto a toothpick.",
            preparationMinutes: 5,
            imageName: "bloodyMarry",
            ingredients: [
                Ingredient(imperialAmount: "1 ½ cups", name: "ice cubes", metricAmount: "360 ml"),
                Ingredient(imperialAmount: "4 fluid ounces", name: "tomato juice", metricAmount: "120 ml"),
                Ingredient(imperialAmount: "1 ½ fluid ounces", name: "vodka", metricAmount: "45 ml"),
                Ingredient(imperialAmount: "¼ fluid ounce", name: "fresh lemon juice", metricAmount: "7 ml"),
                Ingredient(imperialAmount: "4 dashes", name: "hot pepper sauce (such as Tabasco®)", metricAmount: "4 dashes"),
                Ingredient(imperialAmount: "2 dashes", name: "Worcestershire sauce", metricAmount: "2 dashes"),
                Ingredient(imperialAmount: "1 pinch", name: "salt and ground black pepper", metricAmount: "1 pinch"),
                Ingredient(imperialAmount: "1 stalk", name: "celery, for garnish", metricAmount: "1 stalk")
            ]
        ),
        Cocktail(
            id: "9",
            name: "Screwdriver",
            type: .alcoholic,
            shortDescription: "This lively eye-opener adds a spicy kick to brunch.",
            longDescription: "Screwdriver drink is the easiest cocktail recipe that you can make at home with only three ingredients: orange, vodka and ice.",
            preparationMinutes: 1,
            imageName: "screwdriver",
            ingredients: [
                Ingredient(imperialAmount: "1 (1.5 fluid ounce) jigger", name: "good quality vodka", metricAmount: "45 ml"),
                Ingredient(imperialAmount: "6 fluid ounces", name: "pulp-free pure premium orange juice", metricAmount: "180 ml"),
                Ingredient(imperialAmount: "", name: "ice cubes", metricAmount: "")
            ]
        ),
        Cocktail(
            id: "10",
            name: "Old Fashioned",
            type: .alcoholic,
            shortDescription: "The original. A sophisticated cocktail that's simple to make and goes down smooth.",
            longDescription: "The original version of this cocktail was simply water, sugar, bitters, and whatever booze was within reach, often brandy. With time, the water became ice, the booze became whiskey, and the drink became an old fashioned. Serve over ice in a short tumbler (also known as an Old Fashioned glass), garnished with maraschino cherries.",
            preparationMinutes: 5,
            imageName: "oldFashioned",
            ingredients: [
                Ingredient(imperialAmount: "1", name: "sugar cube", metricAmount: "1"),
                Ingredient(imperialAmount: "1 teaspoon", name: "water", metricAmount: "5 ml"),
                Ingredient(imperialAmount: "1 dash", name: "bitters", metricAmount: "1 dash"),
                Ingredient(imperialAmount: "2 fluid ounces", name: "whiskey (rye or bourbon)", metricAmount: "60 ml"),
                Ingredient(imperialAmount: "1", name: "lemon twist", metricAmount: "1"),
                Ingredient(imperialAmount: "", name: "ice cubes", metricAmount: ""),
                Ingredient(imperialAmount: "1", name: "orange slice, for garnish", metricAmount: "1"),
                Ingredient(imperialAmount: "1", name: "maraschino cherry, for garnish", metricAmount: "1")
            ]
        ),
        Cocktail(
            id: "11",
            name: "Margarita Mocktail",
            type: .nonAlcoholic,
            shortDescription: "This delicious gourmet margarita is actually a mocktail. No liquor at all.",
            longDescription: "This delicious non-alcoholic cocktail comes with all the flavors you've come to expect (lime, orange, and a salted rim), a few new surprises (grapefruit and almond) and one notable omission: tequila.",
            preparationMinutes: 5,
            imageName: "margaritaMocktail",
            ingredients: [
                Ingredient(imperialAmount: "2 oz.", name: "honey or agave", metricAmount: "60 ml"),
                Ingredient(imperialAmount: "1 oz.", name: "limeade concentrate", metricAmount: "30 ml"),
                Ingredient(imperialAmount: "1 oz.", name: "fresh lime juice", metricAmount: "30 ml"),
                Ingredient(imperialAmount: "½ oz.", name: "grapefruit juice", metricAmount: "15 ml"),
                Ingredient(imperialAmount: "¼ teaspoon", name: "orange extract or orange bitters", metricAmount: "1.25 ml"),
                Ingredient(imperialAmount: "¾ cup", name: "ice", metricAmount: "180 ml"),
                Ingredient(imperialAmount: "1 tablespoon", name: "flake salt", metricAmount: "15 ml"),
                Ingredient(imperialAmount: "½ teaspoon", name: "chili powder", metricAmount: "2.5 ml"),
                Ingredient(imperialAmount: "", name: "limes for garnish", metricAmount: "")
            ]
        ),
        Cocktail(
            id: "12",
            name: "Non-Alcoholic Juicy Julep",
            type: .nonAlcoholic,
            shortDescription: "Pineapple, orange and lime juices come together in this non-alcoholic version of a favorite cocktail.",
            longDescription: "Here is a beverage all can enjoy, both kids and adults – a non-alcoholic version of the ever-popular mint julep. If you're not drinking, then you might want to try this virgin Juicy Julep. Pineapple, orange and lime juices come together in this non-alcoholic cocktail. It's a delectable drink… That's made even more special with the slice of pineapple on the edge. Yum!",
            preparationMinutes: 6,
            imageName: "nonAlcoholicJuicyJulep",
            ingredients: [
                Ingredient(imperialAmount: "1 measure", name: "pineapple juice", metricAmount: "30 ml"),
                Ingredient(imperialAmount: "1 measure", name: "orange juice", metricAmount: "30 ml"),
                Ingredient(imperialAmount: "1 measure", name: "freshly squeeze lime juice", metricAmount: "30 ml"),
                Ingredient(imperialAmount: "", name: "ginger ale, to top off", metricAmount: ""),
                Ingredient(imperialAmount: "1 teaspoon", name: "mint , crushed or finely chopped", metricAmount: "5 ml"),
                Ingredient(imperialAmount: "", name: "sprig of mint , for garnish", metricAmount: ""),
                Ingredient(imperialAmount: "", name: "lime wedge and/or pineapple slice , for garnish", metricAmount: ""),
                Ingredient(imperialAmount: "", name: "ice", metricAmount: "")
            ]
        )
    ]
}