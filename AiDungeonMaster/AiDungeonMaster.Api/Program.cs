using AiDungeonMaster.Api.Data;
using AiDungeonMaster.Api.IServices;
using AiDungeonMaster.Api.Services;
using Microsoft.EntityFrameworkCore;

namespace AiDungeonMaster.Api
{
    public class Program
    {
        public static void Main(string[] args)
        {
            var builder = WebApplication.CreateBuilder(args);

            // Database
            builder.Services.AddDbContext<AppDbContext>(options =>
                options.UseSqlite(builder.Configuration.GetConnectionString("DefaultConnection")));

            // Add services to the container.
            builder.Services.AddControllers();
            // Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
            builder.Services.AddEndpointsApiExplorer();
            builder.Services.AddSwaggerGen();

            //Register HTTP client for AI services
            builder.Services.AddHttpClient<GeminiAIService>();

            //Add OpenRouter AI service
            builder.Services.AddScoped<IAIService, GeminiAIService>();
            //Add theme service
            builder.Services.AddSingleton<IThemeService, ThemeService>();
            //Add session service
            builder.Services.AddScoped<ISessionService, DbSessionService>();

            //Add player service
            builder.Services.AddScoped<IPlayerService, PlayerService>();

            //Enable CORS for flutter app
            builder.Services.AddCors(options => {
                options.AddPolicy("AllowFlutter", policy =>
                {
                    policy.WithOrigins("http://localhost:5173", "http://127.0.0.1:5173", "http://localhost:8080")
                          .AllowAnyHeader()
                          .AllowAnyMethod();
                });
            });

            var app = builder.Build();

            // Configure the HTTP request pipeline.
            if (app.Environment.IsDevelopment())
            {
                app.UseSwagger();
                app.UseSwaggerUI();
            }

            app.UseHttpsRedirection();
            app.UseCors("AllowFlutter");
            app.UseAuthorization();

            app.MapControllers();

            app.Run();
        }
    }
}
